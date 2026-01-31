extends Area3D

const SPEED = 20.0
const RANGE = 150.0
var traveled_distance = 0.0

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	# current travel distance
	var dist = SPEED * delta
	# adjust new position
	position += transform.basis.z * dist
	# calc total traveled
	traveled_distance += dist
	# Remove when too far
	if traveled_distance > RANGE:
		queue_free()
