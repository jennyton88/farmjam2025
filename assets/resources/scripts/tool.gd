class_name Tool extends Item

@export_category("Weapon Item")
@export var damage: int = 0;
@export var attack_type: String = ""; # swing, forward

@export_category("Refillable Item")
@export var fill_amount: int = 0;
@export var empty: bool = true;

@export_category("Light Item")
@export var on: bool = false;

func _init():
	count = 1;
	edible = false;
	sell_price = -1;
	buy_price = -1;
	unstackable = true;
	sellable = false;
	
	energy_use = -1;


func use(cell: TileData):
	match subtype: 
		ItemSubTypes.LIGHT:
			return set_light();
	
	if (!cell):
		return { "NONE": false };
	
	if (cell || cell.get_custom_data("growable")):
		match subtype:
			ItemSubTypes.HOE:
				return dig_plot(cell);
			ItemSubTypes.WATERING_CAN:
				return water_plot(cell);
	
	return { "NONE": false };


func dig_plot(plot):
	return { "dig": !plot.get_custom_data("plot") };


func water_plot(plot):
	return { "water": plot.get_custom_data("plot"), "water_plant": plot.get_custom_data("planted") };


func attack_foe(_foe):
	pass;


func set_light():
	on = !on;
	return { "on": on };


func setup():
	pass;
