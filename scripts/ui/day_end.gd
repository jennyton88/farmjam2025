extends MarginContainer

signal start_day();

@onready var day = $MarginContainer/VBoxContainer/Label;

var text = "End of Day ";
var day_count = 1;

func change_day():
	day_count += 1;
	day.text = text + ("%d" % day_count);

func _on_start_day_button_down():
	start_day.emit();
