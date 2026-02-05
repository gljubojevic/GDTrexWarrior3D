extends Node3D

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func select(selected:bool):
	const LOGO_METAL_BLUE = preload("uid://r6qxijnrykun")
	if selected:
		%Trex.material_override = LOGO_METAL_BLUE
		%AnimationPlayer.play("QuitAnim/Selected")
	else:
		%Trex.material_override = null
		%AnimationPlayer.stop()
