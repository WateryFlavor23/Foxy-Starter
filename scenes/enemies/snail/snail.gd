class_name Snail
extends Enemies

@onready var death_timer: Timer = %DeathTimer
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var wall_ray: RayCast2D = %WallRay
@onready var floor_ray: RayCast2D = %FloorRay

var move_tween: Tween

func _ready() -> void:
	enemy_name = "snail"
	run_tween()  

func enemy_stomped() -> void:
	health -= 1
	velocity = Vector2(0,0)
	move_tween.kill()
	death_timer.start()
	animated_sprite_2d.play("hit")
	
	if health <= 0:
		var tween: Tween = create_tween()
		tween.tween_interval(0.5)
		tween.tween_callback(die_func)

func check_collision() -> void:
	if wall_ray.is_colliding() or not floor_ray.is_colliding():
		#print("TURN AROUNDDDDDD")
		move_tween.kill()
		direction = direction * -1.0
		scale.x = scale.x * -1.0
		run_tween()

func run_tween() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.tween_interval(0.8)
	tween.tween_property(self, "velocity", speed * direction, 0.2)
	tween.tween_property(self, "velocity", Vector2(0,0), 0.4)
	tween.tween_interval(0.6)
	tween.tween_callback(check_collision)
	
	move_tween = tween

func _on_death_timer_timeout() -> void:
	run_tween()
	animated_sprite_2d.play("walk")
