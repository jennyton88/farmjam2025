extends Control

class_name Dialogue

signal npc_open_shop();
signal npc_start_trade();
signal npc_continue_convo();
signal npc_pay_up();

signal altar_open();

signal time_skip();


enum ConvoType {
	NORMAL,
	CHOICE,
	CHOSEN,
	EXIT,
	NONE,
}

enum CharSubTypes {
	NONE,
	SELLER,
}


@onready var choice = preload("res://scenes/ui/components/textbox.tscn");

@onready var name_box = $NameBox;
@onready var char_name = $NameBox/Name;
@onready var dialogue = $Dialogue;
@onready var choice_box = $ChoiceBox;
@onready var choices = $ChoiceBox/VBoxContainer;


var text_group: Dictionary; # all lines, get it from the storage
var lines_info: Dictionary; # text group to read throughs
var lines: Array; # line in the text group
var curr_line: int = 0;
var added_choices = false;

var curr_npc_name = "";
var curr_npc_subtype = -1;

func _ready():
	hide();
	char_name.set_wrap(TextServer.AutowrapMode.AUTOWRAP_OFF);
	dialogue.type = "dialogue";
	dialogue.clicked_next.connect(_on_clicked_next);


func start_convo(npc_name, subtype):
	curr_npc_name = npc_name;
	curr_npc_subtype = subtype;
	
	curr_line = 0;
	lines_info = text_group[text_group.start];
	if (lines_info["name"]):
		char_name.set_text(curr_npc_name);
		name_box.show();
	else:
		name_box.hide();
	
	lines = lines_info["text"];
	speak_line(lines[curr_line]);
	
	match lines_info.type:
		ConvoType.CHOICE:
			if (!added_choices):
				add_choices();
				added_choices = true;
		ConvoType.CHOSEN:
			if (lines_info.save_choice.has("buy")):
				if (lines_info.save_choice["buy"]):
					npc_open_shop.emit(true);
			elif (lines_info.save_choice.has("test_trade")):
				npc_start_trade.emit();
			elif (lines_info.save_choice.has("skip_time")):
				if (lines_info.save_choice["skip_time"]):
					time_skip.emit();
			elif (lines_info.save_choice.has("sacrifice")):
				if (lines_info.save_choice["sacrifice"]):
					altar_open.emit(true);
				else:
					altar_open.emit(false);
			else:
				npc_open_shop.emit(false);
				altar_open.emit(false);
			
			if (lines_info.save_choice.has("complete_trade")):
				npc_pay_up.emit(lines_info.save_choice["complete_trade"]);
			
			if (lines_info.subtype):
				match lines_info.subtype:
					ConvoType.EXIT:
						if (!added_choices):
							add_choices();
							added_choices = true;
					ConvoType.NONE:
						pass;
					-1:
						pass;
	show();


func speak_line(line):
	dialogue.set_text(line);


func set_curr_line():
	curr_line += 1;
	if (lines_info.type == ConvoType.CHOICE):
		curr_line -= 1;
		if (!added_choices):
			add_choices();
			added_choices = true;
	
	if (curr_line == lines.size()):
		return end_convo();
	speak_line(lines[curr_line]);
	
	return false;


func end_convo():
	if (curr_line == lines.size()):
		text_group.start = lines_info.next;
		
	curr_line = 0;
	hide();
	
	return true;


func add_choices():
	for c in lines_info.choices.size():
		var a_choice = choice.instantiate();
		choices.add_child(a_choice);
		a_choice.set_wrap(TextServer.AutowrapMode.AUTOWRAP_OFF);
		a_choice.set_text(lines_info.choices[c]);
		a_choice.set_type("choice");
		a_choice.id = c;
		a_choice.clicked.connect(_on_clicked_choice);
	
	choice_box.show();


func remove_choices():
	choice_box.hide();
	
	var children = choices.get_children();
	for c in children:
		c.queue_free();


func _on_clicked_choice(id):
	remove_choices();
	added_choices = false;
	if (curr_npc_subtype == CharSubTypes.SELLER && lines_info.subtype == ConvoType.EXIT):
		npc_open_shop.emit(false);
	
	text_group.start = lines_info.jump[id];
	start_convo(curr_npc_name,  curr_npc_subtype);


func _on_clicked_next():
	npc_continue_convo.emit();
