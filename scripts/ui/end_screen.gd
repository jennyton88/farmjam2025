extends MarginContainer

@onready var start = load("res://scenes/ui/start_menu.tscn");

@onready var img_text = $VBoxContainer/TextureRect;
@onready var label = $VBoxContainer/RichTextLabel;

var win = "res://assets/art/endings/win_end.png";
var lose = "res://assets/art/endings/lose_end2.png";

func _on_back_button_down():
	get_tree().change_scene_to_packed(start);


var good_end = ("[center]

Good Ending
You sAcrificed The CROPs and the deities are satisfied for now... They decided not to destroy the whole town!

You win!
Thank you for playing!");




var bad_end = ("[center] 

Bad Ending
The Deities were not satisfied with your offering. the town is now destroyed... Good JOb!

You lose.
Thank you for playing!");


func change_end(ending):
	if (ending == "good"):
		label.text = good_end;
		img_text = load(win);
	elif (ending == "bad"):
		label.text = bad_end;
		img_text = load(lose);
