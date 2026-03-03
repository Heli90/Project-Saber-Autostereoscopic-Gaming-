extends Node3D

@onready var fondu_noir: ColorRect = $FonduLayer/FonduNoir

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var transition = create_tween()
	transition.tween_property(fondu_noir, "modulate:a", 0.0, 0.6)
	await transition.finished
	fondu_noir.visible = false
