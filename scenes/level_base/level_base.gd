extends Node


@onready var spawn_point: Marker2D = %SpawnPoint


func _on_kill_zone_body_entered(_body: Node2D) -> void:
	print("ENTERED")
	SignalHub.on_death(spawn_point.position)
