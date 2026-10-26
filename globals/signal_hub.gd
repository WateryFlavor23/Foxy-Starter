extends Node


signal died(spawn_point: Vector2)

func on_death(spawn_point: Vector2) -> void:
	died.emit(spawn_point)
