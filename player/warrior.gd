extends CharacterBody3D

# define signal when player is dead
signal died()
# define signal when player is hit
signal hit()

@onready var shoot_sound: AudioStreamPlayer = %ShootSound
@onready var damage_sound: AudioStreamPlayer = %DamageSound
@onready var die_sound: AudioStreamPlayer = %DieSound

# definable enargy for player
@export var energy: float = 100.0

# flag for camera mode
var is_camera_first_person: bool = true
# Multiplier for lerping camera move
var CAMERA_MOVE_RATE: float = 1.0
# Weight for moving camera
var camera_move_weight: float = 0.0

# Camera first person position
var first_person_pos: Vector3 = Vector3(0, 3.5, 2.5)
var first_person_rot: Vector3 = Vector3(0, 180, 0)
# Camera third person position
var third_person_pos: Vector3 = Vector3(0, 10, -10)
var third_person_rot: Vector3 = Vector3(-25, 180, 0)

# Camera desired position
var desired_camera_pos: Vector3 = first_person_pos
var desired_camera_rot: Vector3 = first_person_rot
# Camera current position
var current_camera_pos: Vector3 = first_person_pos
var current_camera_rot: Vector3 = first_person_rot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set("mouse_mode", Input.MOUSE_MODE_CAPTURED)
	#camera_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# add correction to level back after turn
	if rotation_degrees.z > 0:
		rotation_degrees.z -= delta * 10
	if rotation_degrees.z < 0:
		rotation_degrees.z += delta * 10
	if abs(rotation_degrees.z) < 0.1:
		rotation_degrees.z = 0
	camera_move(delta)
	camera_shake(delta)

func _physics_process(delta: float) -> void:
	const SPEED = 30
	# get direction movement from actions
	var input_direction_2d = Input.get_vector(
		"move_right", "move_left", "move_back", "move_forward"
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
	camera_move_weight = 1.0
	current_camera_pos = %Camera3D.position
	current_camera_rot = %Camera3D.rotation_degrees
	if is_camera_first_person:
		desired_camera_pos = first_person_pos
		desired_camera_rot = first_person_rot
		#%Camera3D.position = first_person_pos
		#%Camera3D.rotation_degrees = first_person_rot
	else:
		desired_camera_pos = third_person_pos
		desired_camera_rot = third_person_rot
		#%Camera3D.position = third_person_pos
		#%Camera3D.rotation_degrees = third_person_rot

func camera_move(delta:float):
	if camera_move_weight == 0:
		return
	camera_move_weight = lerp(camera_move_weight, 0.0, delta * CAMERA_MOVE_RATE)
	%Camera3D.position = lerp(current_camera_pos, desired_camera_pos, 1.0 - camera_move_weight)
	%Camera3D.rotation_degrees = lerp(current_camera_rot, desired_camera_rot, 1.0 - camera_move_weight)

# The starting range of possible offsets using random values
var CAMERA_SHAKE_STRENGTH_DEFAULT: float = 0.03
# Multiplier for lerping the shake strength to zero
var CAMERA_SHAKE_DECAY_RATE: float = 1.0
# camera shake
var camera_shake_strength:float = 0.0

func camera_shake_trigger() -> void:
	if is_camera_first_person:
		camera_shake_strength = CAMERA_SHAKE_STRENGTH_DEFAULT

func camera_shake(delta:float) -> void:
	if camera_shake_strength == 0:
		return
	camera_shake_strength = lerp(camera_shake_strength, 0.0, delta * CAMERA_SHAKE_DECAY_RATE)
	%Camera3D.h_offset = randf_range(-camera_shake_strength, camera_shake_strength)
	%Camera3D.v_offset = randf_range(-camera_shake_strength, camera_shake_strength)

func shoot(gun:Marker3D):
	# preload bullet scene on game start
	const BULLET_3D = preload("uid://cd3uvgrh2l5nf")
	var new_bullet = BULLET_3D.instantiate()
	new_bullet.is_player_owner = true
	gun.add_child(new_bullet)
	new_bullet.global_transform = gun.global_transform

func shoot_bullet():
	shoot(%Gun1)
	shoot(%Gun2)
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
		camera_shake_trigger()
		hit.emit()
		damage_sound.play()
		return
	# start die process with some animation
	energy = 0
	camera_shake_trigger()
	died.emit()		# emit when died
	die_sound.play()
