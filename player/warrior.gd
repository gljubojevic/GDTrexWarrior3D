extends CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set("mouse_mode", Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	const SPEED = 30
	# get direction movement from actions
	var input_direction_2d = Input.get_vector(
		"move_left","move_right", "move_back", "move_forward"
	)
	# create movement direction based on actions
	var input_direction_3d = Vector3(
		input_direction_2d.x, 0.0, input_direction_2d.y,
	)
	# update velocity based on desired movement
	var direction = transform.basis * input_direction_3d
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	# update velocity for jumping
	velocity.y -= 100.0 * delta # falling velocity
	# update jumping velocity
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = 50.0
	elif Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0
	# update player position
	move_and_slide()

	# shotting bullets
	if Input.is_action_pressed("shoot") and %Timer.is_stopped():
		shoot_bullet()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.2
		%Camera3D.rotation_degrees.x = clamp(
			%Camera3D.rotation_degrees.x, -30, 30
		)
	elif event.is_action("ui_cancel"):
		Input.set("mouse_mode", Input.MOUSE_MODE_VISIBLE)

func shoot_bullet():
	# preload bullet scene on game start
	const BULLET_3D = preload("uid://cd3uvgrh2l5nf")
	# bullet for Gun1
	var new_bullet = BULLET_3D.instantiate()
	new_bullet.is_player_owner = true
	%Gun1.add_child(new_bullet)
	new_bullet.global_transform = %Gun1.global_transform
	# bullet for Gun2
	new_bullet = BULLET_3D.instantiate()
	new_bullet.is_player_owner = true
	%Gun2.add_child(new_bullet)
	new_bullet.global_transform = %Gun2.global_transform
	# auto fire timer
	%Timer.start()
	
