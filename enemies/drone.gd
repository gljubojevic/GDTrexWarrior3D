extends RigidBody3D

@onready var drone_fighter: Node3D = %drone_fighter
@onready var energy = 100.0

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

# reduce energy when hit or die
func take_damage(value: float):
	energy -= value
	if energy < 0:
		queue_free()		# die when no more energy
	else:
		drone_fighter.demage()	# start animation for 
