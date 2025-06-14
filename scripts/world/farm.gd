extends Node2D

signal send_to_world_crop(crop);

@onready var ground = $Ground;
@onready var fence = $Fence;
@onready var plantable = $Soil;
@onready var crops = $PlantBottom;
@onready var tall_crops = $PlantTop;

@export var crop_manager: Crop;

var plot_states = {
	"tilled": Vector2i(4,0),
	"watered": Vector2i(3,0),
	"growable": [
		Vector2i(0,0), 
		Vector2i(0,1), 
		Vector2i(1,1),
		Vector2i(0,3),
		Vector2i(1,2),
	],
	"planted": [
		Vector2i(5,0),
	],
};
 
var plots: Dictionary = {};
var map_atlas_source = 1;

# Called when the node enters the scene tree for the first time.
func _ready():
	# get all of the prepared soil beforehand
	var check_plots = [plot_states.tilled, plot_states.watered];
	for state in check_plots:
		var tilled_plots = get_cells_by_id(state, "ground");
		for t in tilled_plots:
			plots[t] = Plot.new();
			
	var teleports = get_tree().get_nodes_in_group("teleport_areas");
	for tele in teleports:
		tele.monitorable = false;
	

func get_ground_data(player_pos, map_type = "ground"):
	var map = null;
	
	if (map_type == "ground"):
		map = plantable;
	
	var cell = map.local_to_map(map.to_local(player_pos));
	
	var cell_plantable = false;
	var cell_harvestable = false;
	
	if (plots.has(cell)):
		cell_plantable = plots[cell].planted;
		cell_harvestable = plots[cell].harvestable;
	
	return {
		"pos": cell, 
		"data": map.get_cell_tile_data(cell), 
		"planted": cell_plantable,
		"harvestable": cell_harvestable,
	};


func change_tile(change, pos, map_type = "ground", player_pos=Vector2i(0,0)):
	var tile_atlas = 1;
	
	var map = null;
	if (map_type == "ground"):
		map = plantable;
	
	if (change.has("NONE")):
		return;
	
	if (change.has("dig")):
		if (change["dig"]):
			map.set_cell(pos, tile_atlas, plot_states.tilled);
			plots[pos] = Plot.new();
		else:
			if (plots.has(pos)):
				map.set_cell(pos, tile_atlas, plot_states.growable[4]);
				plots.erase(pos);
				crops.set_cell(pos, -1);
				tall_crops.set_cell(Vector2i(pos.x, pos.y - 1), -1);
	elif (change.has("water")):
		if (plots.has(pos)):
			if (change["water"]):
				if (change["water_plant"]):
					map.set_cell(pos, tile_atlas, plots[pos].get_plant_type());
					plots[pos].watered = change["water"];
				else:
					map.set_cell(pos, tile_atlas, plot_states.watered);
					plots[pos].watered = change["water"];
	elif (change.has("plant")):
		map = crops;
		if (plots.has(pos)):
			if (plots[pos].planted):
				return;
			plots[pos].plant_crop(change["plant"]);
			plots[pos].planted = true;
			map.set_cell(pos, tile_atlas, plots[pos].get_plant_type());
	elif (change.has("harvest")):
		if (plots.has(pos)):
			crops.set_cell(pos, -1);
			tall_crops.set_cell(Vector2i(pos.x, pos.y - 1), -1);
			send_to_world_crop.emit(plots[pos].plant_result, pos, player_pos);
			plots[pos].remove_crop(pos, plantable, crops, tall_crops);


func get_cells_by_id(tile_location, map_type = "ground"):
	var map = null;
	if (map_type == "ground"):
		map = plantable;
	return map.get_used_cells_by_id(map_atlas_source, tile_location);


func grow_crops():
	var crop_map = crops;
	var all_crops = crop_map.get_used_cells();
	
	for crop in all_crops:
		if (plots.has(crop) && plots[crop].planted):
			plots[crop].grow_crop(crop, plantable, crops, tall_crops);


func monitor_areas(monitor):
	var teleports = get_tree().get_nodes_in_group("teleport_areas");
	
	for tele in teleports:
		tele.monitorable = monitor;
	
	ground.collision_enabled = monitor;
	fence.collision_enabled = monitor;
