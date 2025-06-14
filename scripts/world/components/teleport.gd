extends Area2D

@onready var right_spawn = $SpawnRight;
@onready var left_spawn = $SpawnLeft;
@onready var top_spawn = $SpawnTop;
@onready var bottom_spawn = $SpawnBottom;

@export var teleport_name = "A";

@export var right_name = "A1";
@export var left_name = "A2";
@export var top_name = "A3";
@export var bottom_name = "A4";

# Called when the node enters the scene tree for the first time.
func _ready():
	name = teleport_name;
	right_spawn.name = right_name;
	left_spawn.name = left_name;
	top_spawn.name = top_name;
	bottom_spawn.name = bottom_name;
