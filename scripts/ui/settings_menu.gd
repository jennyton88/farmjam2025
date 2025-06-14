extends MarginContainer

@onready var back_button = $MarginContainer/VBoxContainer/Back;
@onready var volume_slider = $MarginContainer/VBoxContainer/Volume/HBoxContainer/MarginContainer/SoundSlider;
@onready var volume_number = $MarginContainer/VBoxContainer/Volume/HBoxContainer/Settings2;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass;


func _on_sound_slider_value_changed(value):
	volume_number.text = "%d" % value;


func _on_back_button_down():
	hide();


func _on_quit_button_down():
	get_tree().quit();
