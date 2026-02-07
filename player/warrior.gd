extends CharacterBody3D

# define signal when player is dead
signal died()

@onready var shoot_sound: AudioStreamPlayer = %ShootSound
@onready var damage_sound: AudioStreamPlayer = %DamageSound
@onready var die_sound: AudioStreamPlayer = %DieSound

# definable enargy for player
@export var energy: float = 100.0

# flag for camera mode
var is_camera_first_person: bool = true
# Camera first person position
var first_person_pos: Vector3 = Vector3(0, 2.5, 2.5)
var first_person_rot: Vector3 = Vector3(0, -180, 0)
# Camera third person position
var third_person_pos: Vector3 = Vector3(0, 10, -10)
var third_person_rot: Vector3 = Vector3(-25, -180, 0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set("mouse_mode", Input.MOUSE_MODE_CAPTURED)
	camera_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# add correction to level back after turn
	if rotation_degrees.z > 0:
		rotation_degrees.z -= delta * 10
	if rotation_degrees.z < 0:
		rotation_degrees.z += delta * 10
	if abs(rotation_degrees.z) < 0.1:
		rotation_degrees.z = 0

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

	# switch camera
	if Input.is_action_just_released("camera_switch"):
		is_camera_first_person = !is_camera_first_person
		camera_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		# rotate when turning
		rotation_degrees.z += event.relative.x * 0.2
		rotation_degrees.z = clamp(
			rotation_degrees.z, -10, 10
		)
		# Disable camera vertical rotation
		#%Camera3D.rotation_degrees.x -= event.relative.y * 0.2
		#%Camera3D.rotation_degrees.x = clamp(
		#	%Camera3D.rotation_degrees.x, -30, 30
		#)
	elif event.is_action("ui_cancel"):
		Input.set("mouse_mode", Input.MOUSE_MODE_VISIBLE)

func camera_position():
	%Reticle.visible = is_camera_first_person
	if is_camera_first_person:
		%Camera3D.position = first_person_pos
		%Camera3D.rotation_degrees = first_person_rot
	else:
		%Camera3D.position = third_person_pos
		%Camera3D.rotation_degrees = third_person_rot

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
	%Timer.start()		# auto fire timer
	shoot_sound.play()	# Play sound
	
# reduce energy when hit or die
func take_damage(value: float):
	# no more energy, no more damage
	if energy == 0:
		return
	# do damage
	energy -= value
	if energy > 0:
		damage_sound.play()
		return
	# start die process with some animation
	energy = 0
	died.emit()		# emit when died
	die_sound.play()
