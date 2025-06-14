extends MarginContainer

@onready var world = preload("res://scenes/world/world.tscn");
@onready var credits = preload("res://scenes/ui/credits.tscn");

@onready var settings = $SettingsMenu;

func _on_play_button_down():
	get_tree().change_scene_to_packed(world);

func _on_settings_button_down():
	settings.show();

func _on_credits_button_down():
	get_tree().change_scene_to_packed(credits);


func _on_quit_button_down():
	get_tree().quit();
