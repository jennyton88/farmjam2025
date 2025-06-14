class_name Inventory extends Resource

enum InvTypes {
	PLAYER,
	SELLER,
}

signal update_selection(selection);
signal update_item(item, selection);
signal drop_item_in_world(item);

@export var id: int = -1;
@export var type : InvTypes; 
@export var full: bool;
@export var storage_spaces: int = 5;
@export var storage: Array[ItemSlot];

@export var curr_selection: int = 0;

# helpful functions
func valid_slot(slot_id: int) -> bool:
	return !(slot_id < 0 || slot_id >= storage_spaces);


func compare_items(item_name: String, slot_id: int) -> bool:
	return item_name == storage[slot_id].item.name;


func select_slot(slot_id: int) -> void:
	if (!valid_slot(slot_id) || storage[slot_id].selected):
		return;
	
	for slot in storage:
		slot.selected = false;
	
	storage[slot_id].selected = true;
	curr_selection = slot_id;
	
	update_selection.emit(curr_selection);


func next_selection() -> void:
	var next: int = curr_selection + 1;
	curr_selection = 0 if (next >= storage_spaces) else next;
	select_slot(curr_selection);


# world item
func check_pickupable(item_name: String) -> bool:
	for i in storage_spaces:
		var slot: ItemSlot = storage[i];
		if (!slot.full || (slot.item.name == item_name)):
			return true;
	
	return false;


func drop_inv_item() -> void:
	drop_item(curr_selection);


func drop_item(slot_id: int) -> void:
	if (valid_slot(slot_id)):
		var slot: ItemSlot = storage[slot_id];
		
		if (slot.selected && slot.full):
			drop_item_in_world.emit(slot.item);
			remove_item(slot_id);


func get_world_item_metadata(data: Area2D) -> Dictionary:
	return { 
		"name": data.get_meta("name"), 
		"count": data.get_meta("count"), 
		"type": data.get_meta("type"), 
		"subtype": data.get_meta("subtype"),
	};


# between inv and world item
func pickup_inv_item(item: Area2D) -> void:
	var metadata = get_world_item_metadata(item);
	var inv_item: Item = create_item(item.get_child(0).texture, metadata);
	
	for i in storage_spaces: # same items
		if (storage[i].full):
			if (compare_items(inv_item.name, i)):
				combine_items(inv_item, i);
				return;

	for i in storage_spaces: # any available space
		if (!storage[i].full):
			add_item(inv_item, i);
			return;


# inv item
func use_item(cell_data: Dictionary) -> Dictionary:
	var curr_slot: ItemSlot = storage[curr_selection];
	
	if (!curr_slot.item):
		return { "NONE": false };
	
	var result = null;
	if (cell_data.has("data")):
		if (curr_slot.item.type == curr_slot.item.ItemTypes.TOOL || curr_slot.item.type == curr_slot.item.ItemTypes.SEED):
			result = curr_slot.item.use(cell_data.data);
		else:
			return { "NONE": false };
	else:
		result = curr_slot.item.use(null);
	
	if (cell_data.has("planted") && !cell_data.planted && result.has("plant")):
		curr_slot.item.count -= 1;
		if (curr_slot.item.count <= 0):
			curr_slot.remove_item();
		
		update_item.emit(curr_slot.item, curr_selection);
	
	return result;


func remove_item(slot_id: int) -> void:
	var slot: ItemSlot = storage[slot_id];
	slot.remove_item();
	update_item.emit(slot.item, curr_selection);

func set_item(item: Item, slot_id: int) -> void:
	var slot: ItemSlot = storage[slot_id];
	slot.set_item(item);
	update_item.emit(slot.item, curr_selection);


func combine_items(item: Item, slot_id: int) -> void:
	var slot: ItemSlot = storage[slot_id];
	slot.item.count += item.count;
	update_item.emit(slot.item, slot_id);


func add_item(item: Item, slot_id: int) -> void:
	var slot: ItemSlot = storage[slot_id];
	slot.set_item(item);
	update_item.emit(storage[slot_id].item, slot_id);


# for pickup items
func create_item(item_texture: CompressedTexture2D, data: Dictionary) -> Item:
	var item: Item = null;
	
	match data.type:
		Item.ItemTypes.TOOL:
			item = Tool.new();
		Item.ItemTypes.SEED:
			item = Seed.new();
		Item.ItemTypes.CROP:
			item = Crop.new();
	
	if (item_texture):
		item.texture = item_texture;
	else:
		item.texture = load(item.get_texture_path(data.subtype));
	
	item.name = data.name;
	item.type = data.type;
	item.subtype = data.subtype;
	item.setup();
	
	item.count = data.count;
	
	return item;


func create_new_item(item_name: String, item_count: int, item_type: Item.ItemTypes, item_subtype: Item.ItemSubTypes):
	var data = {
		"name": item_name,
		"type": item_type,
		"subtype": item_subtype,
		"count": item_count,
	};
	
	return create_item(null, data);


func move_data(prev_inv_id: int, inv_id: int, inv_ref: Control, prev_slot_id: int, slot_id: int, split: bool, count: int) -> void:
	if (prev_inv_id == inv_id && prev_slot_id == slot_id): # don't do anything to itself
		select_slot(slot_id);
		return;
	
	
	
	if (prev_inv_id == inv_id):
		var prev_slot: ItemSlot = storage[prev_slot_id];
		var slot: ItemSlot = storage[slot_id];
		
		
		if (!slot.full): # move to empty slot
			if (split):
				var item = prev_slot.item;
				var new_item = create_new_item(item.name, count, item.type, item.subtype);
				var leftover = prev_slot.item.count - count;
				
				set_item(new_item, slot_id);
				
				if (leftover <= 0):
					remove_item(prev_slot_id);
				else:
					prev_slot.item.count -= count;
			else:
				set_item(prev_slot.item, slot_id);
				remove_item(prev_slot_id);
		elif (slot.full && prev_slot.item.name == slot.item.name): # combine
			if (split):
				slot.item.count += count;
				prev_slot.item.count -= count;
			else:
				combine_items(prev_slot.item, slot_id);
				remove_item(prev_slot_id);
		elif (slot.full && prev_slot.item.name != slot.item.name): # swap
			if (!split):
				var temp: Item = slot.item;
				remove_item(slot_id);
				set_item(prev_slot.item, slot_id);
				set_item(temp, prev_slot_id);
			else:
				return;
		
		select_slot(slot_id);
	elif (prev_inv_id != inv_id):
		var prev_slot: ItemSlot = inv_ref.inventory.storage[prev_slot_id];
		var slot: ItemSlot = storage[slot_id];
		
		if (!slot.full): # move to empty slot
			if (split):
				var item = prev_slot.item;
				var new_item = create_new_item(item.name, count, item.type, item.subtype);
				var leftover = prev_slot.item.count - count;
				
				set_item(new_item, slot_id);
				
				if (leftover <= 0):
					remove_item(prev_slot_id);
				else:
					prev_slot.item.count -= count;
			else:
				set_item(prev_slot.item, slot_id);
				inv_ref.inventory.remove_item(prev_slot_id);
		elif (slot.full && prev_slot.item.name == slot.item.name): # combine
			if (split):
				slot.item.count += count;
				prev_slot.item.count -= count;
			else:
				combine_items(prev_slot.item, slot_id);
				inv_ref.inventory.remove_item(prev_slot_id);
		elif (slot.full && prev_slot.item.name != slot.item.name): # swap
			if (!split):
				var temp: Item = slot.item;
				remove_item(slot_id);
				set_item(prev_slot.item, slot_id);
				inv_ref.inventory.set_item(temp, prev_slot_id);
			else:
				return;
			
		select_slot(slot_id);
		inv_ref.inventory.select_slot(prev_slot_id); # check


func reset() -> void:
	for slot_id in storage_spaces:
		remove_item(slot_id);


func restore(inv_state) -> void:
	for slot_id in inv_state.size():
		var item = inv_state[slot_id];
		var new_item = create_new_item(item.name, item.count, item.type, item.subtype);
		add_item(new_item, slot_id);


func combine_like_items() -> void:
	var checked = [];
	for slot_id in storage_spaces:
		var slot_item = storage[slot_id].item;
		if (!slot_item):
			continue;
		
		if (checked.has(slot_item.name)):
			remove_item(slot_id);
			continue;
		
		for s_id in storage_spaces:
			if (slot_id == s_id):
				continue;
			var s_item = storage[s_id].item;
			if (s_item):
				if (s_item.name == slot_item.name):
					combine_items(s_item, slot_id);
					remove_item(s_id);
		
		checked.push_back(slot_item.name);
