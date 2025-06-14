extends MarginContainer

@onready var start = load("res://scenes/ui/start_menu.tscn");

func _on_back_button_down():
	get_tree().change_scene_to_packed(start);
