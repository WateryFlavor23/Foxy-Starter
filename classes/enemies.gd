class_name Enemies
extends CharacterBody2D


@export var speed: Vector2 = Vector2(100.0, 0.0)
@export var health: int = 3

const GROUP_NAME: String = "Enemies"
var enemy_name: String
var direction: float = -1.0

func _physics_process(_delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * _delta
	
	move_and_slide()

func _enter_tree() -> void:
	add_to_group(GROUP_NAME)

func enemy_stomped() -> void:
	pass

func check_collision() -> void:
	pass

func die_func() -> void:
	queue_free()
