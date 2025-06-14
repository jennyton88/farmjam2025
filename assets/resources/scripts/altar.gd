class_name Altar extends Character

@export var altar_inv: Inventory;
@export var requirements = [
	{
		"name": "Wheat",
		"count": 20,
	},
	{
		"name": "Cat Grass",
		"count": 30,
	},
	{
		"name": "Tomatoes",
		"count": 40,
	},
];

func check_sacrifice():
	pass;
