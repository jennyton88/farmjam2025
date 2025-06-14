extends Control

@onready var farm = $Farm;
@onready var docks = $Docks;
@onready var forest = $Forest;
@onready var plaza = $Plaza;
@onready var town = $Town;

enum Locations {
	FARM = 0,
	DOCKS = 1,
	FOREST = 2,
	PLAZA = 3,
	TOWN = 4,
}

func change_location(loc: Locations):
	var loc_list = [
		farm,
		docks,
		forest,
		plaza,
		town,
	];

	for i in loc_list:
		i.hide();
	
	loc_list[loc].show();
