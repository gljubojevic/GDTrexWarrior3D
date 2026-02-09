extends RigidBody3D

# define signal when enemy is dead
signal died()

@onready var drone_fighter: Node3D = %drone_fighter
@onready var player: CharacterBody3D = get_node("/root/arena01/Player")
@onready var damage_sound: AudioStreamPlayer3D = %DamageSound
@onready var die_sound: AudioStreamPlayer3D = %DieSound
@onready var shoot_sound: AudioStreamPlayer3D = $ShootSound
@onready var timer_dead_remove: Timer = %TimerDeadRemove
@onready var timer_shoot: Timer = $TimerShoot
@onready var ray_cast_3d: RayCast3D = %RayCast3D

var energy: float = 100.0
var speed = randf_range(15.0, 20.0)
const MIN_DISTANCE_TO_PLAYER:float = 40.0

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _physics_process(delta: float) -> void:
	# wait till drops on floor to start moving
	if !ray_cast_3d.is_colliding():
		return
	var direction = global_position.direction_to(player.global_position)
	direction.y = 0.0
	var angle_to_player = Vector3.FORWARD.signed_angle_to(direction, Vector3.UP)
	drone_fighter.rotation.y = angle_to_player + PI
	var player_distance = global_position.distance_to(player.global_position)
	# too far from player, keep moving
	if player_distance > MIN_DISTANCE_TO_PLAYER:
		linear_velocity = direction * speed
		if !timer_shoot.is_stopped():
			timer_shoot.stop()
		return
	# close to player, chase
	linear_velocity = Vector3(0,0,0)
	# oriented to player
	var angle_diff = abs(player.rotation.y - angle_to_player)
	if angle_diff < 3:
		if timer_shoot.is_stopped():
			timer_shoot.start()
	else:
		timer_shoot.stop()


# reduce energy when hit or die
func take_damage(value: float):
	# no more energy, no more damage
	if energy == 0:
		return
	# do damage
	energy -= value
	if energy > 0:
		drone_fighter.demage()	# start animation for
		damage_sound.play()
		return
	# start die process with some animation
	energy = 0
	set_physics_process(false)
	var direction = player.global_position.direction_to(global_position)
	var random_upward_force = Vector3.UP * randf_range(5.0, 15.0)
	apply_central_impulse(direction.rotated(Vector3.UP, randf_range(-0.2, 0.2)) * 20.0 + random_upward_force)
	timer_dead_remove.start()	# start timer to remove
	died.emit()					# emit when died
	die_sound.play()

# remove from scene
func _on_timer_dead_remove_timeout() -> void:
	queue_free()	

func _on_timer_shoot_timeout() -> void:
	shoot_bullets()

func shoot(gun:Marker3D):
	# preload bullet scene on game start
	const BULLET_3D = preload("uid://cd3uvgrh2l5nf")
	var new_bullet = BULLET_3D.instantiate()
	new_bullet.is_player_owner = false
	gun.add_child(new_bullet)
	new_bullet.global_transform = gun.global_transform

var primary_guns: bool = true
func shoot_bullets():
	if primary_guns:
		shoot(%Gun1)
		shoot(%Gun2)
	else:
		shoot(%Gun3)
		shoot(%Gun4)
	primary_guns = !primary_guns
	shoot_sound.play()	# Play sound
