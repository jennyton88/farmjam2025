extends CharacterBody2D

signal pause_time(pausing);
signal end_game();

@export var npc_info: Character;
@export var npc_dialogue: CharDialogue;
@export var npc_texture: CompressedTexture2D;


@onready var npc_spr_anim = $AnimatedSprite2D;
@onready var npc_spr = $Sprite2D;
@onready var dialogue_box = $CanvasLayer/DialogueBox;
@onready var visual_inventory = $CanvasLayer/Inventory;

var type = null;
var subtype = null;
var curr_player_talk = null;

var shop_open: bool = false;
var choices_open: bool = false;

var prepared_payments = null;

var change_day = 1;

var playable = false;

func _ready():
	y_sort_enabled = true;
	
	type = npc_info.type;
	subtype = npc_info.subtype;
	
	if (subtype == npc_info.CharSubTypes.SELLER):
		visual_inventory.setup(npc_info.selling_items);
		
		dialogue_box.npc_open_shop.connect(_on_seller_open_shop);
		dialogue_box.npc_start_trade.connect(_on_seller_start_trade);
		dialogue_box.npc_pay_up.connect(_on_seller_pay_up);
		
		if (npc_info.id == 1):
			visual_inventory.add_item(0, "Wheat Seeds", 300, Item.ItemTypes.SEED, Item.ItemSubTypes.WHEAT);
			visual_inventory.add_item(1, "Cat Grass Seeds", 300, Item.ItemTypes.SEED, Item.ItemSubTypes.CAT_GRASS);
			visual_inventory.add_item(2, "Tomato Seeds", 300, Item.ItemTypes.SEED, Item.ItemSubTypes.TOMATO);
			visual_inventory.add_item(3, "Wheat", 20, Item.ItemTypes.CROP, Item.ItemSubTypes.WHEAT_CROP);
			visual_inventory.add_item(4, "Cat Grass", 20, Item.ItemTypes.CROP, Item.ItemSubTypes.CAT_GRASS_CROP);
			visual_inventory.add_item(5, "Tomatoes", 20, Item.ItemTypes.CROP, Item.ItemSubTypes.TOMATO_CROP);
		elif (npc_info.id == 2):
			visual_inventory.add_item(3, "Wheat", 5, Item.ItemTypes.CROP, Item.ItemSubTypes.WHEAT_CROP);
			visual_inventory.add_item(4, "Cat Grass", 5, Item.ItemTypes.CROP, Item.ItemSubTypes.CAT_GRASS_CROP);
			visual_inventory.add_item(5, "Tomatoes", 5, Item.ItemTypes.CROP, Item.ItemSubTypes.TOMATO_CROP);
		elif (npc_info.id == 5):
			visual_inventory.add_item(0, "Tomatoes", 50, Item.ItemTypes.CROP, Item.ItemSubTypes.TOMATO_CROP);
	elif (subtype == npc_info.CharSubTypes.ALTAR):
		visual_inventory.setup(npc_info.altar_inv);
		
		dialogue_box.altar_open.connect(_on_altar_open);
	else:
		if (npc_info.id == 6):
			playable = true;

	dialogue_box.npc_continue_convo.connect(_on_npc_continue_convo);
	
	if (!playable):
		npc_spr_anim.hide();
		npc_spr.texture = npc_texture;
		npc_spr.show();
	else:
		npc_spr.hide();
		npc_spr_anim.show();


func _process(_delta):
	if (playable):
		npc_spr_anim.play(npc_info.name);
		#npc_spr.play("idle");


func start_convo(player):
	curr_player_talk = player;
	pause_time.emit(true);
	#curr_player_talk.visual_inventory.hide();
	
	if (subtype == npc_info.CharSubTypes.SELLER):
		visual_inventory.curr_items = visual_inventory.get_inv_copy();
		curr_player_talk.visual_inventory.curr_items = curr_player_talk.visual_inventory.get_inv_copy();
		dialogue_box.text_group = npc_dialogue["seller_talk"];
	elif (subtype == npc_info.CharSubTypes.ALTAR):
		dialogue_box.text_group = npc_dialogue["altar_talk"];
	elif (subtype == -1):
		pass;
	else:
		if (("%s_%d" % [npc_info.name.to_lower(), change_day]) in npc_dialogue):
			dialogue_box.text_group = npc_dialogue[("%s_%d" % [npc_info.name.to_lower(), change_day])];
		else: # fallback that shouldn't be used as long as all get some dialogue
			dialogue_box.text_group = npc_dialogue[("%s_%d" % [npc_info.name.to_lower(), 1])];
	
	dialogue_box.start_convo(npc_info.name, npc_info.subtype);


func continue_convo():
	if (dialogue_box.added_choices):
		return false;
		
	var line_set = dialogue_box.set_curr_line();
	
	if (line_set):
		pause_time.emit(false);
	
	return line_set;


func stop_convo():
	pause_time.emit(false);
	dialogue_box.end_convo();
	visual_inventory.visible = false;
	if (shop_open && curr_player_talk):
		curr_player_talk.move_inv_down();
		shop_open = false;
	
	curr_player_talk.visual_inventory.show();
	curr_player_talk = false;


func _on_seller_open_shop(shop_visible):
	visual_inventory.visible = shop_visible;
	shop_open = shop_visible;
	if (shop_open && curr_player_talk):
		curr_player_talk.visual_inventory.show();
		curr_player_talk.move_inv_up();
	elif (!shop_open && curr_player_talk):
		#curr_player_talk.visual_inventory.hide();
		curr_player_talk.move_inv_down();


func _on_seller_start_trade():
	prepared_payments = visual_inventory.start_trade();
	
	var line = "";
	if (prepared_payments.pay != 0):
		line += "You pay %d gold" % prepared_payments.pay;
	
	if (prepared_payments.earn != 0):
		if (line != ""):
			line += ", and ";
		line += "I pay you %d gold" % prepared_payments.earn;
	
	if (line == ""):
		line = "Nothing to trade?";
	else:
		line += ". Is that everything?";
	dialogue_box.speak_line(line);


func _on_seller_pay_up(pay_now):
	var line = "";
	
	if (pay_now):
		var money_amt = curr_player_talk.character_info.get_money();
		#visual_inventory.reset_both_inventories(curr_player_talk.visual_inventory.curr_items, prepared_payments.result);
		if (money_amt < prepared_payments.pay):
			line += "You don't have enough money.";
			if (prepared_payments.earn >= prepared_payments.pay):
				prepared_payments.earn -= prepared_payments.pay;
				line += " I'll take the value out of the items you sold me.";
				curr_player_talk.character_info.update_money(prepared_payments.earn);
			else:
				line += " Come back later to buy something.";
				visual_inventory.reset_inventory();
				curr_player_talk.visual_inventory.reset_inventory();
				
				visual_inventory.restore_inventory();
				curr_player_talk.visual_inventory.restore_inventory();
		else:
			line += "Have a good day!";
			var total = -prepared_payments.pay + prepared_payments.earn;
			curr_player_talk.character_info.update_money(total);
			visual_inventory.combine_like_items();
	else:
		line += "Bye. Have a good day!";
		visual_inventory.reset_inventory();
		curr_player_talk.visual_inventory.reset_inventory();
		
		visual_inventory.restore_inventory();
		curr_player_talk.visual_inventory.restore_inventory();
		
	dialogue_box.speak_line(line);


func _on_npc_continue_convo():
	curr_player_talk.talking = !continue_convo();
	if (!curr_player_talk.talking):
		curr_player_talk.visual_inventory.show();

func _on_altar_open(opened):
	visual_inventory.visible = opened;
	shop_open = opened;
		
	if (shop_open && curr_player_talk):
			curr_player_talk.move_inv_up();
	elif (!shop_open && curr_player_talk):
		curr_player_talk.move_inv_down();
		
	if (!shop_open):
		compare_altar_requirements();


func compare_altar_requirements():
	visual_inventory.combine_like_items();
	
	var total = [];
	
	for slot in visual_inventory.inventory.storage:
		if (slot.item):
			var result = npc_info.requirements.filter(func (thing): return (slot.item.name == thing.name) && (slot.item.count >= thing.count));
			if (result):
				for i in result:
					total.push_back(result);
	
	if (total.size() == npc_info.requirements.size()):
		end_game.emit();
