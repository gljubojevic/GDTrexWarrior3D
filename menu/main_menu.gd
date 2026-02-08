extends Node3D

var isStart:bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# check paused when return to main menu
	if get_tree().paused:
		get_tree().paused = false
	%Start.select(isStart)
	%Quit.select(!isStart)
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_released("move_forward") or Input.is_action_just_released("move_back"):
		isStart = !isStart
		%Start.select(isStart)
		%Quit.select(!isStart)

	if Input.is_action_just_released("ui_accept"):
		if isStart:
			get_tree().change_scene_to_file("res://levels/arena01.tscn")
		else:
			get_tree().quit()

	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()
