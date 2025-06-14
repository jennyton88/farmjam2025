extends Resource

class_name Plot


var plot_states = {
	"tilled": Vector2i(4,0),
	"growable": [
		Vector2i(0,0), 
		Vector2i(0,1), 
		Vector2i(1,1),
		Vector2i(0,3),
		Vector2i(1,2),
	],
	"watered": Vector2i(3,0),
	"planted": [
		Vector2i(5,0),
	],
};


var full: bool = false;
var watered: bool = false;
var planted_crop: Seed = null;
var hours_left: float = 0.0;
var harvestable: bool = false;
var planted: bool = false;

var total_hours: float = 0.0;

var plant_states: Array;
var crop_increment: float = 0.0;
var curr_crop_state: int = 1;
var crop_subtype: Item.ItemSubTypes;
var plant_result: Dictionary;

var regrowable: bool = false;


func _init():
	pass;


func plant_crop(crop_seed):
	planted_crop = crop_seed;
	hours_left = planted_crop.grow_hours;
	crop_increment = planted_crop.growth_rate;
	
	full = true;
	
	match planted_crop.subtype:
		planted_crop.ItemSubTypes.CAT_GRASS:
			plant_states = [
				2, # the one tile plants
				Vector2i(0,4), 
				Vector2i(2,5),
				Vector2i(5,5), 
				Vector2i(1,5),
			]
			plant_result = {
				"name": "Cat Grass", #planted_crop.name,
				"type": planted_crop.ItemTypes.CROP,
				"subtype": planted_crop.ItemSubTypes.CAT_GRASS_CROP,
				"count": 1,
			};
			
		planted_crop.ItemSubTypes.TOMATO: 
			plant_states = [
				3,
				Vector2i(0,5), 
				Vector2i(2,5), 
				Vector2i(5,5), 
				Vector2i(3,3), 
				Vector2i(5,3),
				Vector2i(6,3),
				Vector2i(7,3),
			];
			plant_result = {
				"name": "Tomatoes", #planted_crop.name,
				"type": planted_crop.ItemTypes.CROP,
				"subtype": planted_crop.ItemSubTypes.TOMATO_CROP,
				"count": 1,
			};
			regrowable = true;
			total_hours = planted_crop.grow_hours;
		planted_crop.ItemSubTypes.WHEAT: 
			plant_states = [
				2,
				Vector2i(0,6), 
				Vector2i(2,5), 
				Vector2i(5,5),
				Vector2i(6,5),
				Vector2i(4,5),
			];
			plant_result = {
				"name": "Wheat", #planted_crop.name,
				"type": planted_crop.ItemTypes.CROP,
				"subtype": planted_crop.ItemSubTypes.WHEAT_CROP,
				"count": 1,
			};
										# -1 for the seed state already there,
										# -1 for the 1 tile size plants counter
	crop_increment = planted_crop.grow_hours / (plant_states.size() - 2);
	#crop_increment = snappedf(crop_increment, 0.1);


func grow_crop(pos, water_map, crop_map, tall_crop_map):
	if (!harvestable):
		if (watered):
			hours_left -= planted_crop.growth_rate * 2;
			watered = false;
			water_plot(water_map, pos);
		else:
			hours_left -= planted_crop.growth_rate;
		
		if (hours_left <= crop_increment * ((plant_states.size() - 2) - curr_crop_state)):
			curr_crop_state += 1;
			if (!(curr_crop_state >= plant_states.size())):
				if (curr_crop_state > plant_states[0]):
					plant_next_stage(crop_map, tall_crop_map, plant_states[curr_crop_state], pos, true);
				else:
					plant_next_stage(crop_map, tall_crop_map, plant_states[curr_crop_state], pos, false);
			
			if (hours_left <= 0.0):
				harvestable = true;
	
	#if (!harvestable && hours_left <= 0.0):
		#harvestable = true;
		#plant_next_stage(crop_map, tall_crop_map, plant_states[plant_states.size() - 1], pos, true);


func remove_crop(pos, water_map, crop_map, tall_crop_map) -> void:
	harvestable = false;
	
	if (regrowable):
		hours_left = total_hours / 2;
		curr_crop_state = int(curr_crop_state / 2.0);
		grow_crop(pos, water_map, crop_map, tall_crop_map);
	else:
		hours_left = 0.0;
		watered = false;
		full = false;
		planted_crop = null;
		planted = false;
		curr_crop_state = 1;


func get_plant_type() -> Vector2i:
	return plant_states[curr_crop_state];


func water_plot(water_map, pos):
	var tile_atlas = 1;
	var tile = plot_states.tilled;
	
	if (watered):
		tile = plot_states.watered;
	
	water_map.set_cell(pos, tile_atlas, tile);


func plant_next_stage(crop_map, tall_crop_map, plant_type, pos, tall):
	var tile_source = 1;
	
	if (tall):
		tall_crop_map.set_cell(Vector2i(pos.x, pos.y - 1), tile_source, Vector2i(plant_type.x, plant_type.y - 1));
	
	crop_map.set_cell(pos, tile_source, plant_type);
