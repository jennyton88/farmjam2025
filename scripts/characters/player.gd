extends CharacterBody2D

signal check_tile(pos);
signal change_tile(change, pos);

signal send_to_world_item(item);
signal send_to_world_harvest(pos);
signal world_load_area(scene_name);
signal world_hide_stats();

signal world_end_game();
signal world_time_skip();

const SPEED = 100.0;
const SPRINT_SPEED = 200.0;


enum CharTypes {
	PLAYER,
	NPC,
	SELLER,
	ENEMY,
}

@export var character_info: Character;
@export var inv: Inventory;

@onready var visual_inventory: Control =$CanvasLayer/Inventory;
@onready var pickup: Area2D = $PickUpZone;

@onready var player_spr = $PlayerSprite;
@onready var player_anims = $AnimationPlayer;
@onready var camera = $Camera2D;

@onready var lantern = $PointLight2D;

@onready var settings = $CanvasLayer/SettingsMenu;
@onready var health = $CanvasLayer/Panel/Health;
@onready var energy = $CanvasLayer/Panel2/Energy;
@onready var money = $CanvasLayer/Panel3/Money;
@onready var map = $CanvasLayer/Map;

#@onready var player_audio = $AudioStreamPlayer;

var curr_cell_data = {};


var can_talk = false;
var talking = false;
var talkable_npcs = [];

var no_move = false;

var can_pickup = false;
var pickable_items = [];

var on_farm = false;

var running = false;

var curr_direction = Vector2(0,1);

var split_menu = false;


func _ready() -> void:
	get_parent().send_cell_data.connect(_on_world_send_cell_data);
	get_parent().on_farm.connect(_on_world_check_farm);
	
	character_info.update_visual_money.connect(_on_update_money);
	character_info.update_visual_health.connect(_on_update_health);
	character_info.ko.connect(_on_ko);
	
	visual_inventory.setup(inv);
	
	visual_inventory.opened_split_menu.connect(_on_opened_split_menu);
	
	visual_inventory.add_item(0, "Hoe", 1, Item.ItemTypes.TOOL, Item.ItemSubTypes.HOE);
	visual_inventory.add_item(1, "Watering Can", 1, Item.ItemTypes.TOOL, Item.ItemSubTypes.WATERING_CAN);
	visual_inventory.add_item(2, "lantern", 1, Item.ItemTypes.TOOL, Item.ItemSubTypes.LIGHT);
	visual_inventory.add_item(3, "Cat Grass Seeds", 5, Item.ItemTypes.SEED, Item.ItemSubTypes.CAT_GRASS);
	visual_inventory.add_item(4, "Wheat Seeds", 5, Item.ItemTypes.SEED, Item.ItemSubTypes.WHEAT);
	visual_inventory.add_item(5, "Tomato Seeds", 5, Item.ItemTypes.SEED, Item.ItemSubTypes.TOMATO);
	
	#visual_inventory.add_item(0, "Tomatoes", 40, Item.ItemTypes.CROP, Item.ItemSubTypes.TOMATO_CROP);
	#visual_inventory.add_item(1, "Wheat", 20, Item.ItemTypes.CROP, Item.ItemSubTypes.WHEAT_CROP);
	#visual_inventory.add_item(2, "Cat Grass", 30, Item.ItemTypes.CROP, Item.ItemSubTypes.CAT_GRASS_CROP);
#
	#
	health.text = "HP: %d" % character_info.health;
	energy.text = "EN: %d" % character_info.energy;
	money.text = "$: %d" % character_info.money;

func _physics_process(_delta) -> void:
	if (talking || no_move): # freeze player
		velocity = Vector2.ZERO;
		
		if (velocity == Vector2.ZERO):
			if (curr_direction == Vector2(0,1)): # down
				player_spr.offset.x = -8;
				player_spr.play("idle");
			elif (curr_direction == Vector2(0,-1)): # up
				player_spr.offset.x = -8;
				player_spr.play("idle_back");
			elif (curr_direction == Vector2(-1,0)): # left
				player_spr.offset.x = -11;
				player_spr.play("idle_left");
			if (curr_direction == Vector2(1,0)): # right
				player_spr.offset.x = -11;
				player_spr.play("idle_right");
		return;
	
	var run_speed = SPEED;
	
	if (running):
		run_speed = SPRINT_SPEED;
	
	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_vector("left", "right", "up", "down");
	if direction:
		curr_direction = direction;
		velocity = direction * run_speed;
		if (velocity.x < 0):
			player_spr.offset.x = -11;
			player_spr.play("run_left");
		elif (velocity.x > 0):
			player_spr.offset.x = -11;
			player_spr.play("run_right");
		elif (velocity.y > 0):
			player_spr.offset.x = -8;
			player_spr.play("run_front");
		elif (velocity.y < 0):
			player_spr.offset.x = -8;
			player_spr.play("run_back");
			
		#if (!player_audio.playing):
			#player_audio.play();
	else:
		velocity.x = move_toward(velocity.x, 0, run_speed);
		velocity.y = move_toward(velocity.y, 0, run_speed);
	
	if (velocity == Vector2.ZERO):
		#player_audio.stop();
		if (curr_direction == Vector2(0,1)): # down
			player_spr.offset.x = -8;
			player_spr.play("idle");
		elif (curr_direction == Vector2(0,-1)): # up
			player_spr.offset.x = -8;
			player_spr.play("idle_back");
		elif (curr_direction == Vector2(-1,0)): # left
			player_spr.offset.x = -11;
			player_spr.play("idle_left");
		if (curr_direction == Vector2(1,0)): # right
			player_spr.offset.x = -11;
			player_spr.play("idle_right");
	
	move_and_slide();


func switch_speed(run):
	running = run;


func _unhandled_input(event) -> void:
	if (event is InputEventKey):
		if (event.is_action_pressed("interact")):
			if (can_pickup):
				pickup_item();
			elif (talking && can_talk):
				var result = false;
				if (talkable_npcs[0].name.contains("Area")):
					result = talkable_npcs[0].get_parent().continue_convo();
				else:
					result = talkable_npcs[0].continue_convo();
				if (result):
					talking = false;
			elif (can_talk && !talking):
				if (talkable_npcs[0].name.contains("Area")):
					talkable_npcs[0].get_parent().start_convo(self);
				else: 
					talkable_npcs[0].start_convo(self);
				talking = true;
			else:
				if (on_farm):
					check_tile.emit(global_position);
					
					if (curr_cell_data.has("harvestable")):
						if (curr_cell_data["harvestable"]):
							harvest(curr_cell_data);
					var update_cell = visual_inventory.use_item(curr_cell_data);
					if (update_cell.has("on")):
						lantern.visible = update_cell["on"];
					else:
						change_tile.emit(update_cell, curr_cell_data.pos, Vector2i.ZERO);
				else:
					var update_cell = visual_inventory.use_item(curr_cell_data);
					if (update_cell.has("on")):
						lantern.visible = update_cell["on"];
		elif (event.is_action_pressed("s1")):
			visual_inventory._on_clicked_slot(0);
		elif (event.is_action_pressed("s2")):
			visual_inventory._on_clicked_slot(1);
		elif (event.is_action_pressed("s3")):
			visual_inventory._on_clicked_slot(2);
		elif (event.is_action_pressed("s4")):
			visual_inventory._on_clicked_slot(3);
		elif (event.is_action_pressed("s5")):
			visual_inventory._on_clicked_slot(4);
		elif (event.is_action_pressed("s6")):
			visual_inventory._on_clicked_slot(5);
		elif (event.is_action_pressed("s7")):
			visual_inventory._on_clicked_slot(6);
		#elif (event.is_action_pressed("switch_slot")):
			#visual_inventory.next_selection();
		elif (event.is_action_pressed("drop")):
			drop_item();
		elif (event.is_action_pressed("settings")):
			settings.visible = !settings.visible;
			health.get_parent().visible = !settings.visible;
			energy.get_parent().visible = !settings.visible;
			money.get_parent().visible = !settings.visible;
			world_hide_stats.emit(settings.visible); # should move those
		elif (event.is_action_pressed("sprint")):
			switch_speed(true);
		elif (event.is_action_released("sprint")):
			switch_speed(false);
		elif (event.is_action_pressed("map")):
			open_map();
		#elif (event.is_action_pressed("enter")):
			#print("pressed enter ", split_menu ,"\n")
			#if (split_menu):
				#print(visual_inventory.split_line.text);
				#if (visual_inventory.split_line.text.is_valid_int()):
					#visual_inventory.split_items();
					#split_menu = false;
					#visual_inventory.cancel_split();
					#print("splitted\n")
				#else:
					#split_menu = false;
					#visual_inventory.cancel_split();
					#print("canceled\n")


func harvest(cell_data):
	send_to_world_harvest.emit(cell_data.pos, global_position);


func pickup_item():
	if (visual_inventory.check_pickupable(pickable_items[0])):
		return;
	
	visual_inventory.pickup_inv_item(pickable_items[0]);
	pickable_items[0].queue_free();
	remove_pickable_item(pickable_items[0].name);
	if (pickable_items.size() <= 0):
		can_pickup = false;


func drop_item():
	visual_inventory.drop_inv_item();


func _on_world_send_cell_data(cell_data: Dictionary) -> void:
	curr_cell_data = cell_data;


func _on_pick_up_zone_body_entered(body):
	if (body.type == CharTypes.NPC):
		can_talk = true;
		talkable_npcs.push_back(body);
		if (body.npc_info.subtype == character_info.CharSubTypes.ALTAR):
			if (!body.end_game.is_connected(_on_altar_end_game)):
				body.end_game.connect(_on_altar_end_game);


func _on_pick_up_zone_body_exited(body):
	if (body.type == CharTypes.NPC):
		if (talking):
			body.stop_convo();
			talking = false;
		remove_npc(body.name);
		if (talkable_npcs.size() == 0):
			can_talk = false;


func remove_npc(npc_name):
	for i in talkable_npcs.size():
		if (talkable_npcs[i].name == npc_name):
			talkable_npcs.pop_at(i);
			break;


func remove_pickable_item(item_name):
	for i in pickable_items.size():
		if (pickable_items[i].name == item_name):
			pickable_items.pop_at(i);
			break;


func _on_inventory_create_item_in_world(item) -> void:
	send_to_world_item.emit(item, global_position);


func _on_pick_up_zone_area_entered(area) -> void:
	if (area.collision_layer == 0b100):
		can_pickup = true;
		pickable_items.push_back(area);
	elif (area.collision_layer == 0b100000):
		talkable_npcs.push_back(area);
		can_talk = true;
	else:
		world_load_area.emit(area.name);


func _on_pick_up_zone_area_exited(area) -> void:
	if (area.collision_layer == 0b100): # item
		remove_pickable_item(area.name);
		if (pickable_items.size() == 0):
			can_pickup = false;
	elif (area.collision_layer == 0b100000):
		remove_npc(area.name);
		if (talkable_npcs.size() == 0):
			can_talk = false;


func move_inv_up() -> void:
	visual_inventory.position = Vector2(20, 80);


func move_inv_down() -> void:
	visual_inventory.position = Vector2(42, 142);


func _on_world_check_farm(truth) -> void:
	on_farm = truth;


func _on_update_money(money_left):
	money.text = "$: %d" % money_left;
	
func _on_update_health(health_left):
	health.text = "HP: %d" % health_left;


func open_map():
	map.visible = !map.visible;


func _on_altar_end_game():
	world_end_game.emit();


func _on_opened_split_menu(opened):
	no_move = opened;


func damage(taken_damage):
	character_info.update_health(-taken_damage);
	player_anims.play("damaged");


func _on_ko():
	world_time_skip.emit();
