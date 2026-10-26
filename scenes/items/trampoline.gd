class_name Trampoline
extends Area2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var boing_sound: AudioStreamPlayer = %BoingSound

@export var bounce_velocity: float = -600.0

func apply_bounce(body: Player) -> void:
	print("BODY DETECTED")
	body.velocity.y = bounce_velocity
	animated_sprite_2d.play("default")
	boing_sound.play()
