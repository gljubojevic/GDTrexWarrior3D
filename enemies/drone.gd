extends RigidBody3D

@onready var drone_fighter: Node3D = %drone_fighter
@onready var energy: float = 100.0
@onready var player: CharacterBody3D = get_node("/root/arena01/Player")

var speed = randf_range(5.0, 10.0)

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	linear_velocity = direction * speed
	drone_fighter.rotation.y = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP) + PI

# reduce energy when hit or die
func take_damage(value: float):
	energy -= value
	if energy < 0:
		queue_free()		# die when no more energy
	else:
		drone_fighter.demage()	# start animation for 
