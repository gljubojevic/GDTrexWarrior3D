extends Area3D

const SPEED = 20.0
const RANGE = 150.0
const DAMAGE = 10.0
var traveled_distance = 0.0
var is_player_owner: bool = true

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

# move bullet
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

# bullet hit something
func _on_body_entered(body: Node3D):
	# check player don't kill himself
	if body is CharacterBody3D and is_player_owner:
		return
	# check enemyy don't kill himself
	if body is RigidBody3D and !is_player_owner:
		return
	# bullet hit something that is allowed
	queue_free()		# remove bullet
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE)
