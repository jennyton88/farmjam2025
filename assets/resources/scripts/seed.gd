class_name Seed extends Item

@export var grow_hours: float;
@export var crop_amount: int;
@export var growth_rate: float;


func _init():
	sell_price = 10;
	buy_price = 15;
	
	edible = true;
	unstackable = false;
	sellable = true;
	
	energy_use = -1;


func use(cell: TileData):
	if (!cell):
		return { "NONE": false };
	
	if (cell.get_custom_data("plot") && !cell.get_custom_data("planted")):
		return { "plant": self };
	
	return { "NONE": false };


func setup():
	match subtype:
		ItemSubTypes.WHEAT:
			grow_hours = 20;
			growth_rate = 1;
		ItemSubTypes.TOMATO:
			grow_hours = 40;
			growth_rate = 1;
		ItemSubTypes.CAT_GRASS:
			grow_hours = 12;
			growth_rate = 1;
