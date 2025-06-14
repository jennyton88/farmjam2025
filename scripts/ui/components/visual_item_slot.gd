extends MarginContainer

signal clicked(id);
signal update_content;
signal move_slot_data(prev_inv_id, inv_id, inv_ref, prev_slot_id, slot_id, split, count);
signal show_item_data(id);

signal open_split_menu(id);

@onready var selection = $Selected;
@onready var img = $Control/MarginContainer/TextureRect;
@onready var count = $Control/MarginContainer2/Label;

var inv_id = -1;
var id = -1;
var item_name = "";


func set_id(num: int) -> void:
	id = num;


func selected(select: bool) -> void:
	selection.visible = select;


func counter_visible(shown: bool) -> void:
	count.visible = shown;


func texture_visible(shown: bool) -> void:
	img.visible = shown;


func set_texture(texture: CompressedTexture2D) -> void:
	img.texture = texture;


func set_item_name(this_item_name) -> void:
	item_name = this_item_name;


func set_count(counter: int) -> void:
	count.text = "%d" % counter;


func _gui_input(event) -> void:
	if (event is InputEventMouseButton):
		if (event.is_action_pressed("left_click")):
			clicked.emit(id);
			if (inv_id != 0): # TODO cHANGE
				show_item_data.emit(id);
		elif(event.is_action_pressed("right_click")):
			open_split_menu.emit(id);


func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	if (typeof(data) == TYPE_DICTIONARY):
		if (data.has("name") && data.has("id")):
			return true;
	
	return false;


func _drop_data(_position: Vector2, data: Variant) -> void:
	move_slot_data.emit(data.inv_id, inv_id, data.inv_ref, data.id, id, data.split, data.count);
	update_content.emit();


func _get_drag_data(_position: Vector2) -> Variant:
	if (item_name == ""):
		return;
	
	var data = { 
		"name": item_name, 
		"id": id, "inv_id": inv_id, 
		"inv_ref": get_parent().get_parent(),
		"count": int(count.text),
		"split": false,
	};
	
	img.hide();
	count.hide();
	
	var draggable_content = create_drag_preview();
	
	set_drag_preview(draggable_content);
	
	return data;


func _notification(what) -> void:
	if (what == NOTIFICATION_DRAG_END):
		if (!is_drag_successful()):
			update_content.emit();

func create_drag_preview():
	var draggable_content = Control.new();
	var a_texture = TextureRect.new();
	
	draggable_content.add_child(a_texture);
	draggable_content.z_index = 1;
	
	a_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST;
	a_texture.texture = img.texture;
	a_texture.position = -0.5 * Vector2(16,16);
	
	return draggable_content;


func grab_amount(num):
	var data = { 
		"name": item_name, 
		"id": id, "inv_id": inv_id, 
		"inv_ref": get_parent().get_parent(),
		"count": num,
		"split": true,
	};
	
	count.text = "%d" % (int(count.text) - num);
	
	force_drag(data, create_drag_preview());
