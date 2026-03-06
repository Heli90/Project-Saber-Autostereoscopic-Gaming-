extends Node3D

@onready var cube_tournant: Node3D = $CubeTournant
@onready var j1: CharacterBody3D = $SplitScreens/Camera1/POV1/J1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("StopGame"):
		cube_tournant._onPartieTimerTimeout()
