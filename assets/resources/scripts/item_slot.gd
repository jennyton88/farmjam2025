extends Resource

class_name ItemSlot

@export var full: bool = false;
@export var item: Item = null;
@export var selected: bool;


func set_item(slot_item):
	if (slot_item):
		item = slot_item;
		full = true;
	else:
		remove_item();


func drop_item():
	remove_item();


func remove_item():
	item = null;
	full = false;
