extends Node3D

const MAX_ACTIVE_ENEMIES:int = 3

# define signal when new enemy is created
signal enemy_spawned(enemy)

# Editor propery to select enemy type to spawn
@export var enemy_to_spawn: PackedScene = null
# marker where to create new enemy
@onready var marker_3d: Marker3D = %Marker3D
# sound player for spawned sounds
@onready var spawned_sound: AudioStreamPlayer3D = $SpawnedSound

# default timer wait to spawn new enemy
const DEFAULT_SPAWN_WAIT:float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# nothing spawned jet
	enemies_spawned = 0
	# randomize timer start and start it
	%Timer.wait_time = randf_range(DEFAULT_SPAWN_WAIT/2, DEFAULT_SPAWN_WAIT)
	%Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

# currently spawned enemies
static var enemies_spawned:int = 0
# triggered when enemy dies
func enemy_died():
	enemies_spawned -=1

func _on_timer_timeout() -> void:
	# restore default timer time
	if %Timer.wait_time != DEFAULT_SPAWN_WAIT:
		%Timer.wait_time = DEFAULT_SPAWN_WAIT
	# check can we spawn new enemy
	if enemies_spawned >= MAX_ACTIVE_ENEMIES:
		return
	# spawn
	var new_enemy = enemy_to_spawn.instantiate()
	add_child(new_enemy)
	new_enemy.global_position = marker_3d.global_position
	# emit signal for new enemy
	enemy_spawned.emit(new_enemy)
	spawned_sound.play()
	enemies_spawned += 1
	# subscribe to enemy died signal
	new_enemy.died.connect(enemy_died)
