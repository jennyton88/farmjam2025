extends Node2D

signal world_time_skip();
signal pause_time();

@onready var dialogue_box = $CanvasLayer/DialogueBox;

var bed_talk = {};

var player = null;


func _ready():
	bed_talk = {
		"start": 0,
		"reset_start": 0,
		0: {
			"name": false,
			"type": dialogue_box.ConvoType.CHOICE, "subtype": dialogue_box.ConvoType.EXIT,
			"text": [ "Go to sleep?" ],
			"choices": ["Yes.", "Not yet."],
			"jump": [1,2], "next": 2,
		},
		1: {
			"name": false,
			"type": dialogue_box.ConvoType.CHOSEN, "subtype": dialogue_box.ConvoType.NONE,
			"save_choice": { "skip_time": true, },
			"text": ["What a sleep!"],
			"next": 0,
		},
		2: {
			"name": false,
			"type": dialogue_box.ConvoType.CHOSEN, "subtype": dialogue_box.ConvoType.NONE,
			"save_choice": { "skip_time": false, },
			"text": [ "Gotta keep working." ],
			"next": 0,
		},
	};
	
	dialogue_box.text_group = bed_talk;
	dialogue_box.time_skip.connect(_on_time_skip);
	dialogue_box.npc_continue_convo.connect(_on_npc_continue_convo);


func start_convo(player_info):
	pause_time.emit(true);
	dialogue_box.start_convo("", -1);
	player = player_info;


func stop_convo():
	pause_time.emit(false);
	dialogue_box.end_convo();
	dialogue_box.visible = false;
	if (player):
		player.talking = false;
		player = null;


func _on_time_skip():
	stop_convo();
	dialogue_box.visible = false;
	world_time_skip.emit();


func _on_npc_continue_convo():
	if (player):
		player.talking = !continue_convo();
	else:
		bed_talk.start = bed_talk.reset_start;
		dialogue_box.visible = false;


func continue_convo():
	if (dialogue_box.added_choices):
		return false;
		
	var line_set = dialogue_box.set_curr_line();
	
	if (line_set):
		pause_time.emit(false);
	
	return line_set;
