extends Resource

class_name Item

enum ItemTypes {
	FORAGE,
	SEED,
	CROP,
	TOOL,
}

enum ItemSubTypes {
	HOE = 0,
	WATERING_CAN = 1,
	LIGHT = 2,
	PITCHFORK = 3,
	SWORD = 4,
	DAGGERS = 5,
	WHEAT = 6,
	TOMATO = 7,
	CAT_GRASS = 8,
	WHEAT_CROP = 9,
	TOMATO_CROP = 10,
	CAT_GRASS_CROP = 11,
}

@export var texture: Texture2D = null;
@export var name: String;

@export var energy_use: int = 0;
@export var count: int = 0;

@export_category("Item Features")
@export var edible: bool = true;
@export var unstackable: bool = false;
@export var droppable: bool = true;
@export var sellable: bool = true;

@export_category("Item Price")
@export var sell_price: int = 0;
@export var buy_price: int = 0;

@export_category("Item Type")
@export var type: ItemTypes;
@export var subtype: ItemSubTypes;

var _item_texture_paths: Dictionary = {
	ItemSubTypes.HOE: "res://assets/art/tools/hoe.png",
	ItemSubTypes.WATERING_CAN: "res://assets/art/tools/water_can.png",
	ItemSubTypes.LIGHT: "res://assets/art/tools/lantern.png",
	ItemSubTypes.PITCHFORK: "res://assets/art/tools/pitchfork.png",
	ItemSubTypes.SWORD: "",
	ItemSubTypes.DAGGERS: "",
	ItemSubTypes.WHEAT: "res://assets/art/seeds/wheat_seeds.png",
	ItemSubTypes.TOMATO: "res://assets/art/seeds/tomato_seeds.png",
	ItemSubTypes.CAT_GRASS: "res://assets/art/seeds/cat_grass_seeds.png",
	ItemSubTypes.WHEAT_CROP: "res://assets/art/crops/wheat.png",
	ItemSubTypes.TOMATO_CROP: "res://assets/art/crops/tomatoes.png",
	ItemSubTypes.CAT_GRASS_CROP: "res://assets/art/crops/cat_grass.png",
};

func get_texture_path(item_subtype: ItemSubTypes) -> String:
	return _item_texture_paths[item_subtype];
