class_name Pig
extends Enemies

@export var mad_speed: Vector2 = Vector2(200, 0)

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var wall_ray: RayCast2D = %WallRay
@onready var player_ray: RayCast2D = %PlayerRay
@onready var floor_ray: RayCast2D = %FloorRay
@onready var enrage_timer: Timer = %EnrageTimer

var is_enraged: bool = false 
var dir_changeable = true
var tween: Tween

func _ready() -> void:
	velocity = speed * direction
	animated_sprite_2d.play("walk_calm")

func _physics_process(_delta: float) -> void:
	if !is_on_floor():
		velocity += get_gravity() * _delta
	
	move_and_slide()
	call_deferred("check_collision")

func enemy_stomped() -> void:
	health -= 1
	
	if tween:
		tween.kill()
	
	tween = create_tween()

	tween.tween_callback(animated_sprite_2d.play.bind("hit_mad"))
	tween.tween_property(self, "velocity", Vector2(0,0), 0.1)
	
	is_enraged = true
	enrage_timer.start()
	
	tween.tween_interval(1.0)
	tween.tween_callback(animated_sprite_2d.play.bind("walk_mad"))
	
	tween.tween_property(self, "velocity", mad_speed * direction, 0.3)
	
	if health <= 0:
		tween.tween_interval(0.5)
		tween.tween_callback(die_func)

func check_collision() -> void:
	if wall_ray.is_colliding() or not floor_ray.is_colliding():
		call_deferred("apply_collision")

func apply_collision() -> void:
	direction *= -1
	scale.x *= -1
	print("DIRECTION IS NOW %d" % direction)
	
	if !is_enraged:
		tween = create_tween()
		tween.tween_callback(animated_sprite_2d.play.bind("idle_calm"))
		tween.tween_property(self, "velocity", Vector2(0,0), 0.1)
		tween.tween_interval(1.0)
		tween.tween_callback(animated_sprite_2d.play.bind("walk_calm"))
		tween.tween_property(self, "velocity", speed * direction, 0.3)
	else: velocity = mad_speed * direction

func _on_enrage_timer_timeout() -> void:
	is_enraged = false
	animated_sprite_2d.play("walk_calm")
	velocity = speed * direction
