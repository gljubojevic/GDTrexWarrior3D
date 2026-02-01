extends RigidBody3D

@onready var drone_fighter: Node3D = %drone_fighter
@onready var player: CharacterBody3D = get_node("/root/arena01/Player")
@onready var timer: Timer = %Timer

var energy: float = 100.0
var speed = randf_range(15.0, 20.0)

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
	# no more energy, no more damage
	if energy == 0:
		return
	# do damage
	energy -= value
	if energy > 0:
		drone_fighter.demage()	# start animation for
		return
	# start die process with some animation
	energy = 0
	set_physics_process(false)
	var direction = player.global_position.direction_to(global_position)
	var random_upward_force = Vector3.UP * randf_range(5.0, 15.0)
	apply_central_impulse(direction.rotated(Vector3.UP, randf_range(-0.2, 0.2)) * 20.0 + random_upward_force)
	# start timer to remove
	timer.start()

# remove from scene
func _on_timer_timeout() -> void:
	queue_free()	
