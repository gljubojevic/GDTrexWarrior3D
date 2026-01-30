extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set("mouse_mode", Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * 0.5
		%Camera3D.rotation_degrees.x -= event.relative.y * 0.2
		%Camera3D.rotation_degrees.x = clamp(%Camera3D.rotation_degrees.x, -30, 30)
	elif event.is_action("ui_cancel"):
		Input.set("mouse_mode", Input.MOUSE_MODE_VISIBLE)
		
