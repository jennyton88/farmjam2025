extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D;
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D;

var movement_speed: float = 70.0;
var movement_target_position: Vector2 = Vector2(60.0,180.0);

var attack_damage = 15;

var player = null;
var return_spot = null;

var current_target = null;

var attack_player = false;
var seconds = 60 * 2;
var counter = 0;

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	return_spot = get_parent().get_node("Home");
	
	navigation_agent.path_desired_distance = 4.0;
	navigation_agent.target_desired_distance = 4.0;

	# Make sure to not await during _ready.
	actor_setup.call_deferred();

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame;

	# Now that the navigation map is no longer empty, set the movement target.
	#set_movement_target(movement_target_position);

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target;


func _physics_process(_delta):
	if (attack_player):
		attack();
	
	if (navigation_agent.is_navigation_finished()):
		if (current_target):
			if (current_target == player):
				if (navigation_agent.is_target_reachable()): # continue chase
					set_movement_target(current_target.global_position);
				else:
					current_target = return_spot;
			if (current_target == return_spot):
				set_movement_target(return_spot.global_position);
				current_target = return_spot;
				player = null;
		else:
			set_movement_target(return_spot.global_position);
			current_target = return_spot;
		
		sprite.stop();
		return;
	
	var current_agent_position: Vector2 = global_position;
	var next_path_position: Vector2 = navigation_agent.get_next_path_position();
	
	velocity = current_agent_position.direction_to(next_path_position) * movement_speed;
	move_and_slide();
	
	if (current_target):
		set_movement_target(current_target.global_position);
		if (current_target.global_position - global_position < Vector2.ZERO):
			sprite.offset.x = -13;
			sprite.play("walk_left");
		else:
			sprite.offset.x = 13;
			sprite.play("walk_right");


func _on_vision_body_entered(body):
	if (body.name.contains("Player")):
		player = body;
		current_target = player;
		set_movement_target(body.global_position);


func _on_vision_body_exited(body):
	if (body.name.contains("Player")):
		player = null;
		current_target = null;
		
func attack():
	if (counter >= seconds):
		if (player):
			player.damage(attack_damage);
		counter = 0;
	counter += 1;


func _on_hit_area_body_entered(body):
	if (body.name.contains("Player")):
		attack_player = true;


func _on_hit_area_body_exited(body):
	if (body.name.contains("Player")):
		attack_player = false;
		counter = 0;
