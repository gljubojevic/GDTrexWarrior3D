extends Node3D

# Editor propery to select enemy type to spawn
@export var enemy_to_spawn: PackedScene = null

@onready var marker_3d: Marker3D = %Marker3D

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _on_timer_timeout() -> void:
	var new_enemy = enemy_to_spawn.instantiate()
	add_child(new_enemy)
	new_enemy.global_position = marker_3d.global_position
