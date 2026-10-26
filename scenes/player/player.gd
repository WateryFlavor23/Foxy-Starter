class_name Player
extends CharacterBody2D


@export var cam_limit_left: int = -1000000
@export var cam_limit_right: int = 1000000
@export var cam_limit_top: int = -1000000
@export var cam_limit_bottom: int = 1000000

@onready var jump_sound: AudioStreamPlayer = %JumpSound
@onready var land_sound: AudioStreamPlayer = %LandSound
@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var player_camera: Camera2D = %PlayerCamera
@onready var hurt_timer: Timer = %HurtTimer
@onready var damage_sound: AudioStreamPlayer = %DamageSound
@onready var invincibility_timer: Timer = %InvincibilityTimer

const SPEED = 150.0
const JUMP_VELOCITY = -400.0
const STOMP_VELOCITY = -300.0

var is_still: bool:
	get: return is_zero_approx(velocity.x)
var is_falling: bool:
	get: return velocity.y > 0
var _was_on_floor: bool = false
var _is_hurt: bool = false
var _is_invincible: bool = false
var _damage_bodies: Array[CharacterBody2D]

func _ready() -> void:
	set_camera()
	SignalHub.died.connect(respawn)

func _physics_process(_delta: float) -> void:
	handle_move_input()
	
	if !is_on_floor():
		velocity += get_gravity() * _delta
		_was_on_floor = false
	
	move_and_slide()
	
	check_grounded_status()

func handle_move_input() -> void:
	var input = Input.get_axis("left", "right")
	velocity.x = SPEED * input
	
	flip_sprite(input)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

func set_camera() -> void:
	player_camera.limit_left = cam_limit_left
	player_camera.limit_right = cam_limit_right
	player_camera.limit_top = cam_limit_top
	player_camera.limit_bottom = cam_limit_bottom

func flip_sprite(input: float) -> void:
	if input < 0: sprite_2d.flip_h = true
	elif input > 0: sprite_2d.flip_h = false

func check_grounded_status() -> void:
	if not _was_on_floor and is_on_floor():
		land_sound.play()
		_was_on_floor = true

func respawn(spawn_point: Vector2) -> void:
	global_position = spawn_point
	set_position.call_deferred(spawn_point)

func apply_hurt_logic() -> void:
	if _is_invincible: return
	else:
		#print("start hurt logic.")
		_is_hurt = true
		hurt_timer.start()
		damage_sound.play()
		
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite_2d, "position", Vector2(0.0, -20), 0.1)
		tween.set_parallel(false)
		tween.tween_property(sprite_2d, "position", Vector2(0.0, 0), 0.1)

func apply_invincibility() -> void:
	if _is_invincible: return
	else:
		#print("start invincible logic.")
		_is_invincible = true
		invincibility_timer.start()
		
		var tween: Tween = create_tween()
		tween.set_loops(5)
		tween.parallel().tween_property(sprite_2d, "self_modulate", Color(1,1,1,0.25), 0.1)
		tween.tween_property(sprite_2d, "self_modulate", Color(1,1,1,1), 0.1)

func apply_stomp() -> void:
	velocity.y = STOMP_VELOCITY

func _on_hitbox_body_entered(body: Node2D) -> void:
	apply_hurt_logic()
	apply_invincibility()
	
	if !(body in _damage_bodies):
		_damage_bodies.append(body)

func _on_hitbox_body_exited(body: Node2D) -> void:
	_damage_bodies.erase(body)

func _on_hurt_timer_timeout() -> void:
	_is_hurt = false
	damage_sound.stop()

func _on_invincibility_timer_timeout() -> void:
	#print("NOW VULNERABLE")
	_is_invincible = false
	
	if _damage_bodies.size() > 0:
		apply_hurt_logic()
		apply_invincibility()

func _on_stomp_area_entered(area: Area2D) -> void:
	if  velocity.y < 0.0 or _is_invincible: return
	
	if area is Trampoline:
		(func(): area.apply_bounce(self)).call_deferred()
	
	if area.get_parent().is_in_group("Enemies"):
		print("stomped parent")
		
		area.get_parent().enemy_stomped()
		apply_stomp.call_deferred()
		area.trigger()
