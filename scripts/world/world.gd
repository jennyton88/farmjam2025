extends Node2D

signal send_cell_data(pos);
signal on_farm(truth);

enum Locations {
	FARM = 0,
	DOCKS = 1,
	FOREST = 2,
	PLAZA = 3,
	TOWN = 4,
}

@onready var town = preload("res://scenes/world/town.tscn");
@onready var dock = preload("res://scenes/world/dock.tscn");
@onready var farm_house = preload("res://scenes/world/farm_house.tscn");
@onready var forest = preload("res://scenes/world/forest.tscn");
@onready var plaza = preload("res://scenes/world/plaza.tscn");
@onready var town_elder_house = preload("res://scenes/world/town_elder_house.tscn");


@onready var end_screen = $CanvasLayer/EndScreen;

var curr_scene: Node2D = null;

@onready var farm = $Farm;

@onready var player := $Player as CharacterBody2D;

@onready var day = $DayTimer;
@onready var time_clock = $CanvasLayer/Panel/Label;
@onready var sky_time = $CanvasModulate;
@onready var fade = $CanvasLayer/Fade;

@onready var animate = $AnimationPlayer;

@onready var ended_day = $CanvasLayer/DayEnd;

var morning_color = Color.WHITE;
var night_color = Color("550093");

var intensity = 0.0;

var npc_home = false;

var current_day = 1;
var days_left = 6;

# TIMER

var given_time = 20 * 60;#day.start(20 * 60); # minutes * seconds

var switched_time = false;
var start_time_offset = 6;
var time_offset = start_time_offset;
var time_offset_seconds = 0;

var diff_seconds = 0;

var time_of_day = {
	"morning": " AM",
	"night": " PM",
};

#TIMER END

var scene_items = {
	"Dock": [],
	"Farm": [],
	"FarmHouse": [],
	"Forest": [],
	"Plaza": [],
	"Town": [],
	"TownElderHouse": [],
};

var startup = false;


func _ready() -> void:
	farm.monitor_areas(false);
	#fade.hide();
	
	set_scene("Farm", "Dock");
	
	ended_day.start_day.connect(_on_start_day);
	
	player.check_tile.connect(_on_player_check_tile);
	player.change_tile.connect(_on_player_change_tile);
	player.send_to_world_item.connect(_on_player_send_item);
	player.world_load_area.connect(_on_player_load_area);
	player.send_to_world_harvest.connect(_on_player_send_harvest);
	player.world_hide_stats.connect(_on_player_hide_stats);
	
	player.world_time_skip.connect(_on_world_time_skip);
	player.world_end_game.connect(_on_end_game);
	
	farm.send_to_world_crop.connect(_on_farm_send_crop);
	
	move_child(player, -1);
	
	sky_time.color = morning_color;
	day.start(given_time);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time_left: int = int(day.time_left); 
	var seconds: int = time_left % 60;
	
	if (seconds != diff_seconds):
		diff_seconds = seconds;
		if (seconds % 10 == 0):
			farm.grow_crops();
			
			time_offset_seconds += 10;
			if (switched_time):
				intensity += 10;
				sky_time.color = morning_color.lerp(night_color, intensity / 600);
			
		if (seconds % 60 == 0):
			time_offset_seconds = 0;
			time_offset += 1;
			if (time_offset == 12):
				switched_time = !switched_time;
			elif (time_offset == 13):
				time_offset = 1;
			elif (switched_time && time_offset == 9):
			#elif (time_offset == 7):
				npc_home = true;
				npc_leave();
	
	if (seconds % 10 == 0):
		var time_string = "[center]%d:%d" if (seconds != 0) else "[center]%d:0%d";
		time_string = time_string % [time_offset, time_offset_seconds];
		
		if (switched_time):
			time_string += time_of_day.night;
		else:
			time_string += time_of_day.morning;
			
		time_clock.text = time_string;


func _on_player_check_tile(player_pos):
	var data = farm.get_ground_data(player_pos, "ground"); # fix this later
	send_cell_data.emit(data);


func _on_player_change_tile(change, pos, player_pos):
	farm.change_tile(change, pos, "ground", player_pos);


func _on_player_send_item(item, player_pos):
	var dropped_item = Area2D.new();
	var spr = Sprite2D.new();
	var body = CollisionShape2D.new();
	
	dropped_item.add_child(spr);
	dropped_item.add_child(body);
	
	dropped_item.global_position = player_pos;
	dropped_item.monitoring = false;
	
	body.shape = CircleShape2D.new();
	body.shape.radius = 5;
	
	if (typeof(item) == TYPE_DICTIONARY):
		var a_item = Item.new();
		spr.texture = load(a_item.get_texture_path(item.subtype));
	else:
		spr.texture = item.texture;
	spr.scale = Vector2(0.7, 0.7);
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;
	
	dropped_item.collision_layer = 0b100; # item
	dropped_item.collision_mask = 0b0; # nothing
	
	dropped_item.set_meta("type", item.type);
	dropped_item.set_meta("subtype", item.subtype);
	dropped_item.set_meta("name", item.name);
	dropped_item.set_meta("count", item.count);
	
	add_child(dropped_item);
	scene_items[curr_scene.name].push_back(dropped_item);


func _on_world_time_skip():
	day.stop();
	_on_day_timer_timeout();


func _on_pause_time(pausing):
	day.paused = pausing;


func _on_player_load_area(scene_name):
	call_deferred("set_scene", curr_scene.name, scene_name); # need to wait for areas to set

func set_scene(curr_scene_name, scene_name):
	fade_to_black(true);
	
	if (curr_scene_name == scene_name):
		set_spawn();
		player.camera.reset_smoothing();
		fade_to_black(false);
		
		return;
	
	var removal = curr_scene;
	
	# farm scene is saved so plants continue to grow
	if (curr_scene_name.contains("Farm") && !curr_scene_name.contains("House")):
		on_farm.emit(false);
		farm.monitor_areas(false);
		farm.hide();
		removal = null;
		curr_scene = null;
	else:
		removal = curr_scene;
		curr_scene = null;
	
	# send all objects like npcs out of the main tree from current scene
	var y_sorts = get_tree().get_nodes_in_group("y_sort");
	if (y_sorts):
		for a_node in y_sorts:
			a_node.queue_free();
	

	# spawn scene based on their name and unique objects within
	if (scene_name.contains("Dock")):
		curr_scene = dock.instantiate();
	elif (scene_name.contains("Town") && scene_name.contains("Elder")):
		curr_scene = town_elder_house.instantiate();
	elif (scene_name.contains("Town")):
		curr_scene = town.instantiate();
	elif (scene_name.contains("Forest")):
		curr_scene = forest.instantiate();
	elif (scene_name.contains("Plaza")):
		curr_scene = plaza.instantiate();
	elif (scene_name.contains("House")):
		curr_scene = farm_house.instantiate();
		
		var bed = curr_scene.get_node("Bed");
		bed.pause_time.connect(_on_pause_time);
		bed.world_time_skip.connect(_on_world_time_skip);
	elif (scene_name.contains("Farm") && !scene_name.contains("House")):
		curr_scene = farm;
		
		farm.show();
		farm.monitor_areas(true);
		on_farm.emit(true);


	if (scene_name.contains("Farm") && !scene_name.contains("House")):
		pass;
	else:
		add_child(curr_scene);
		curr_scene.z_index = -1;
		move_child(curr_scene, 0);
		

	var tilemap = curr_scene.get_child(0); # assume ground is first child
	var re = tilemap.get_used_rect();

	player.camera.limit_top = re.position.y * 16;
	player.camera.limit_bottom = (re.position.y + re.size.y) * 16;
	player.camera.limit_left = re.position.x * 16;
	player.camera.limit_right = (re.position.x + re.size.x) * 16;
	
	set_spawn();
	
	if (removal):
		removal.queue_free();
	
	# add every object the player can walk around, connect signals for npc
	y_sorts = get_tree().get_nodes_in_group("y_sort");
	
	if (y_sorts):
		for a_node in y_sorts:
			a_node.reparent(self, true);
			if (a_node.name.contains("Npc")):
				a_node.change_day = current_day;
				if (!a_node.pause_time.is_connected(_on_pause_time)):
					a_node.pause_time.connect(_on_pause_time);
	
	if (npc_home):
		npc_leave();
	
	move_child(player, -1); # player always on top
	
	# save ref. to dropped items, and show/hide for their scene
	var curr_items = scene_items[curr_scene_name];
	for i in curr_items.size():
		if (is_instance_valid(curr_items[i])):
			curr_items[i].monitorable = false;
			curr_items[i].hide();
	
	for i in range(curr_items.size()-1, -1, -1):
		if (!is_instance_valid(curr_items[i])):
			curr_items.pop_at(i);
	
	var items = scene_items[curr_scene.name];
	for i in items.size():
		if (is_instance_valid(items[i])):
			items[i].monitorable = true;
			items[i].show();
	
	for i in range(items.size()-1, -1, -1):
		if (!is_instance_valid(items[i])):
			items.pop_at(i);
		
	var node_path = "";
	if (scene_name.contains("Right")):
		node_path = curr_scene_name + "Left/";
	elif (scene_name.contains("Left")):
		node_path = curr_scene_name + "Right/";
	elif (scene_name.contains("Top")):
		node_path = curr_scene_name + "Bottom/";
	elif (scene_name.contains("Bottom")):
		node_path = curr_scene_name + "Top/";
	
	if (node_path != ""): # for teleport areas w/o setting scene manually
		node_path += scene_name;
		var spawn = curr_scene.get_node(node_path as NodePath);
		if (spawn):
			player.global_position = spawn.global_position;
	
	player.camera.reset_smoothing();
	
	update_map();
	fade_to_black(false);


func fade_to_black(fade_anim):
	if (fade_anim):
		animate.play("fade_in");
	else:
		animate.play("fade_out");
	#sky_time.color = Color.BLACK; # can do this for the forest or something

func _on_farm_send_crop(crop, _pos, player_pos):
	_on_player_send_item(crop, player_pos);

func _on_player_send_harvest(cell_pos, player_pos):
	_on_player_change_tile({ "harvest": true }, cell_pos, player_pos);


func update_map():
	var location = -1;
	
	if (curr_scene.name.contains("Farm")): # both places
		location = Locations.FARM;
	elif (curr_scene.name == "Dock"):
		location = Locations.DOCKS;
	elif (curr_scene.name == "Plaza"):
		location = Locations.PLAZA;
	elif (curr_scene.name == "Forest"):
		location = Locations.FOREST;
	elif (curr_scene.name.contains("Town")):
		location = Locations.TOWN;
	
	player.map.change_location(location);


func _on_end_game():
	end_screen.change_end("good");
	end_screen.show();


func bad_end_game():
	end_screen.change_end("bad");
	end_screen.show();

func _on_day_timer_timeout():
	startup = false;
	
	player.curr_direction = Vector2(0,1);
	player.no_move = true;
	ended_day.show();
	set_scene(curr_scene.name, "FarmHouse");
	
	sky_time.color = morning_color;
	intensity = 0.0;
	#call_deferred("set_scene", curr_scene.name, "FarmHouse");


func set_spawn():
	if (!startup):
		var spawn = curr_scene.get_node("SpawnPoint");
		if (spawn):
			player.global_position = spawn.global_position;
		startup = true;


func _on_start_day():
	time_offset = start_time_offset;
	time_offset_seconds = 0;
	diff_seconds = 0;
	switched_time = false;
	
	ended_day.hide();
	ended_day.change_day();
	current_day += 1;
	
	days_left -= 1;
	
	if (days_left == -1):
		bad_end_game();
		return;
	
	player.character_info.update_health(200);
	player.no_move = false;
	player.talking = false;
	
	npc_home = false;
	day.start(given_time);


func _on_player_hide_stats(stat_hidden):
	time_clock.get_parent().visible = !stat_hidden;


func npc_leave():
	var y_sorts = get_tree().get_nodes_in_group("y_sort");
	if (y_sorts):
		for a_node in y_sorts:
			if (a_node.name.contains("Npc")):
				a_node.queue_free();
