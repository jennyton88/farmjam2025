extends Item

class_name Crop

enum CropTypes {
	WHEAT_CROP = 9,
	TOMATO_CROP = 10,
	CAT_GRASS_CROP = 11,
}

func _init():
	pass;
	
func setup():
	match subtype:
		CropTypes.WHEAT_CROP:
			count = 1;
			energy_use = 10;
			sell_price = 50;
			buy_price = 60;
		CropTypes.TOMATO_CROP:
			count = 1;
			energy_use = 5;
			sell_price = 25;
			buy_price = 30;
		CropTypes.CAT_GRASS_CROP:
			count = 1;
			energy_use = 20;
			sell_price = 200;
			buy_price = 250;



func use(a):
	return {"NONE":false}
