extends Node3D

@onready var label_score: Label = %LabelScore
var player_score:int = 0
@onready var progress_energy: ProgressBar = %ProgressEnergy
@onready var player: CharacterBody3D = %Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	progress_energy.value = player.energy

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func increase_score():
	player_score += 1
	label_score.text = "Score: " + str(player_score)

# track spawned enemies to capture signal when they are died
func _on_enemy_spawner_3d_enemy_spawned(enemy) -> void:
	enemy.died.connect(increase_score)

func _on_player_died() -> void:
	print("Game over!")
	progress_energy.value = 0

func _on_player_hit() -> void:
	progress_energy.value = player.energy
