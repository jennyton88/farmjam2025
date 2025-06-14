extends MarginContainer

signal clicked(id);
signal clicked_next;

@onready var label = $MarginContainer/RichTextLabel;
@onready var hover = $Hover;

var type = "";
var id = -1;

func set_type(text_type):
	type = text_type;

func set_text(words):
	label.text = words;


func _gui_input(event):
	if (event is InputEventMouseButton):
		if (event.is_action_pressed("left_click")):
			if (type == "choice"):
				clicked.emit(id);
			if (type == "dialogue"):
				clicked_next.emit();


func set_wrap(wrap_mode):
	label.autowrap_mode = wrap_mode;


func _on_mouse_entered():
	if (type == "choice"):
		hover.show();


func _on_mouse_exited():
	if (type == "choice"):
		hover.hide();
