class_name Character extends Resource

signal update_visual_money(money);
signal update_visual_health(health);
signal ko();

enum CharTypes {
	PLAYER,
	NPC,
	ENEMY,
}

enum CharSubTypes {
	NONE,
	SELLER,
	ALTAR,
}

@export var name: String;
@export var health: int = 100;
@export var energy: int = 100;
@export var money: int = 500;
@export var type: CharTypes;
@export var subtype: CharSubTypes;
@export var id: int;


func update_energy(): # +/- in same func
	pass;


func update_health(health_points: int) -> void:
	health += health_points;
	if (health > 100):
		health = 100;
	update_visual_health.emit(health);
	if (health <= 0):
		ko.emit();
	# add a limit for max health


func update_money(money_amt: int) -> void:
	money += money_amt;
	update_visual_money.emit(money);


func get_money() -> int:
	return money;
