extends MarginContainer

signal create_item_in_world(item);

signal opened_split_menu(opened);

@export var inventory: Inventory;

@onready var item_slot: PackedScene = preload("res://scenes/ui/components/item_slot.tscn");
@onready var grid = $GridContainer;
@onready var split_menu = $SplitMenu;
@onready var split_line = $SplitMenu/LineEdit;


var item_slots = [];
var curr_items = null;

var limit_chars = "0123456789";
var split_item_id = -1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;
	#z_index = 1;


func setup(inv):
	inventory = inv;
	create_inv(inventory);
	
	inventory.update_selection.connect(_on_update_selection);
	inventory.update_item.connect(_on_update_item);
	inventory.drop_item_in_world.connect(_on_drop_item_in_world);
	
	if (inventory.id == 0):
		grid.columns = inventory.storage_spaces;


func create_inv(inv: Inventory) -> void:
	for i in inv.storage_spaces:
		var slot: Control = item_slot.instantiate() as Control;
		grid.add_child(slot);
		
		slot.id = i;
		slot.inv_id = inventory.id;
		
		slot.custom_minimum_size = Vector2(18, 18);
		slot.mouse_filter = MOUSE_FILTER_STOP;
		
		slot.clicked.connect(_on_clicked_slot);
		slot.update_content.connect(_on_update_content);
		slot.move_slot_data.connect(_on_move_slot_data);
		slot.show_item_data.connect(_on_show_item_data);
		slot.open_split_menu.connect(_on_open_split_menu);
		
		item_slots.push_back(slot);
	
	update_selection(inv.curr_selection);
	update_inv(inv);


func update_selection(selection):
	for slot in item_slots:
		slot.selected(false); # could do prev selection
		
	item_slots[selection].selected(true);


func update_inv(inv): # only if dropping / using item
	for slot_id in inv.storage_spaces:
		var inv_slot: ItemSlot = inv.storage[slot_id];
		var slot = item_slots[slot_id];
		if (inv_slot.item):
			slot.set_texture(inv_slot.item.texture);
			slot.set_count(inv_slot.item.count);
			slot.set_item_name(inv_slot.item.name);
			slot.texture_visible(true);
			
			if (inv_slot.item.type == Item.ItemTypes.TOOL):
				slot.counter_visible(false);
			else:
				slot.counter_visible(true);
		else:
			slot.set_item_name("");
			slot.counter_visible(false);
			slot.texture_visible(false);


func use_item(curr_cell_data: Dictionary) -> Dictionary:
	return inventory.use_item(curr_cell_data);


func next_selection() -> void:
	inventory.next_selection();


func check_pickupable(pickable_item: Area2D) -> bool:
	return !inventory.check_pickupable(pickable_item.get_meta("name"));


func pickup_inv_item(pickable_item: Area2D) -> void:
	inventory.pickup_inv_item(pickable_item);


func drop_inv_item() -> void:
	inventory.drop_inv_item();


func _on_update_selection(selection):
	update_selection(selection);


func _on_update_item(item: Item, selection: int) -> void:
	var inv_slot = item_slots[selection];
	if (!item):
		inv_slot.set_item_name("");
		inv_slot.counter_visible(false);
		inv_slot.set_texture(null);
		inv_slot.texture_visible(false);
	else:
		inv_slot.set_item_name(item.name);
		inv_slot.set_count(item.count);
		inv_slot.set_texture(item.texture);
		inv_slot.texture_visible(true);
		
		if (item.type == Item.ItemTypes.TOOL):
			inv_slot.counter_visible(false);
		else:
			inv_slot.counter_visible(true);


func _on_clicked_slot(slot_id):
	inventory.select_slot(slot_id);


func _on_drop_item_in_world(item):
	create_item_in_world.emit(item);


func _on_update_content():
	update_inv(inventory);


func _on_move_slot_data(prev_inv_id, inv_id, inv_ref, prev_slot_id, slot_id, split, count):
	inventory.move_data(prev_inv_id, inv_id, inv_ref, prev_slot_id, slot_id, split, count);


func _on_show_item_data(slot_id):
	var item = inventory.storage[slot_id].item;
	var dialogue = get_parent().get_child(1);
	
	if (item):
		dialogue.speak_line("%d" % item.buy_price + " gold per " + item.name + ".");
		#if (item.name.ends_with('s')):
			#dialogue.speak_line(item.name + " are %d" % item.sell_price +  " gold.");
		#else:
			#dialogue.speak_line(item.name + " is %d" % item.sell_price +  " gold.");


func get_inv_copy():
	var stored_items = [];
	for slot in inventory.storage:
		if (slot.item):
			stored_items.push_back({
				"name": slot.item.name, 
				"count": slot.item.count, 
				"buy_price": slot.item.buy_price, 
				"sell_price": slot.item.sell_price,
				"type": slot.item.type,
				"subtype": slot.item.subtype,
			});
	
	return stored_items;


func start_trade(): # should move to inventory?
	var modified_items = get_inv_copy();
	
	var curr_check = combine_collection(curr_items);
	var mod_check = combine_collection(modified_items);
	
	#print("\n___RECEIPT START___\n")
	#for i in curr_check:
		#print("cur: ",i.name, ": ", i.count, "\n");
	#for i in mod_check:
		#print("mod: ", i.name, ": ", i.count, "\n");
	#print("\n___________________\n")
	
	var result = filter_seller_items(curr_check, mod_check);
	
	var paying = 0;
	var earning = 0;
	
	#for i in result:
		#print("result: ", i.name,": ", i.count, " amt | ", " buy" if i.buy else "", " sell" if i.sell else "", "\n");
	
	for item in result:
		if (item.buy):
			paying += item.buy_price * item.count;
		elif (item.sell):
			earning += item.sell_price * item.count;
	#print("\n____________________________\n")
	#print( "total: pay: ", paying, " gold, earn: ", earning, " gold \n")
	#print("\n______HAVE A NICE DAY_______\n")
	
	return { "pay": paying, "earn": earning, "result": result };


# original list to check against, current list
func filter_seller_items(items_1: Array, items_2: Array) -> Array:
	var different = [];
	
	if (items_1.size() == 0): # out of stock
		if (items_2.size() != 0):
			for item in items_2:
				var result = {
					"name": item.name,
					"sell": true, # player selling
					"buy": false, # player buying
					"count": item.count,
					"buy_price": item.buy_price,
					"sell_price": item.sell_price,
				};
				different.push_back(result);
		
		return different;
	
	for item in items_1: # for singular items bought out of stock
		var exists = items_2.filter(func(thing): return (
			thing.name == item.name
		));
		
		if (exists.size() == 0): # if it doesn't exist in items_2, then bought
			var result = {
				"name": item.name,
				"sell": false, # player selling
				"buy": true, # player buying
				"count": item.count,
				"buy_price": item.buy_price,
				"sell_price": item.sell_price,
			};
				
			different.push_back(result);
	
	# when unique items are being sold to seller
	for item in items_2:
		var compare_items = items_1.filter(func(thing): return (
			thing.name == item.name
		));
		
		if (compare_items.size() == 0):
			var result = {
				"name": item.name,
				"sell": true, # player selling
				"buy": false, # player buying
				"count": item.count,
				"buy_price": item.buy_price,
				"sell_price": item.sell_price,
			};
			
			different.push_back(result);
	
	
	for item in items_2: # specifically for items that are the same but needs to check their change
		var compare_items = items_1.filter(func(thing): return (
			thing.name == item.name && thing.count != item.count
		));
		
		var compare_same_items = items_1.filter(func(thing): return (
			thing.name == item.name && thing.count == item.count
		));
		
		var result = {
			"name": item.name,
			"sell": false, # player selling
			"buy": false, # player buying
			"count": item.count,
			"buy_price": item.buy_price,
			"sell_price": item.sell_price,
		};
		
		for compar in compare_same_items:
			different.push_back(result);
		
		# if nothing then this is skipped
		for compar in compare_items: # compare difference if exists
			var leftover = item.count - compar.count;
			if (leftover > 0): # selling
				result.sell = true;
				result.count = leftover;
			elif (leftover < 0): # buying
				result.buy = true;
				result.count = leftover * -1;
			
			different.push_back(result);
	
	return different;

# combine all same named items, for comparison
func combine_collection(items: Array):
	var comparable = [];
	
	var checked_names = [];
	for item in items:
		if (checked_names.has(item.name)):
			continue;
		checked_names.push_back(item.name);
		var addable = items.filter(func(thing): return thing.name == item.name);
		var added = { 
			"name": addable[0].name, 
			"count": 0,
			"buy_price": addable[0].buy_price,
			"sell_price": addable[0].sell_price,
		};
		
		for add in addable:
			added["count"] += add.count;
		
		comparable.push_back(added);
	return comparable;


func add_item(slot_id, item_name, count, type, subtype):
	var item = inventory.create_new_item(item_name, count, type, subtype); 
	inventory.add_item(item, slot_id);


func reset_inventory():
	inventory.reset();
	_on_update_content();


func restore_inventory():
	if (curr_items):
		inventory.restore(curr_items);


func combine_like_items():
	inventory.combine_like_items();


func split_items():
	var item = inventory.storage[split_item_id].item;
	
	var count = int(split_line.text);
	if (item && count > 0):
		if (count >= item.count):
			count = item.count;
		
		item_slots[split_item_id].grab_amount(count);
	
	cancel_split();


#func reset_both_inventories(player_inv, items):
	#for item in items:
		#if (item.sell): # from player


func _on_open_split_menu(id):
	split_item_id = id;
	split_menu.visible = true;
	opened_split_menu.emit(true);


func cancel_split():
	split_menu.hide();
	split_line.text = "";
	split_item_id = -1;
	opened_split_menu.emit(false);


func _on_line_edit_text_submitted(new_text):
	if (new_text.is_valid_int()):
		split_items();
	else:
		cancel_split();
