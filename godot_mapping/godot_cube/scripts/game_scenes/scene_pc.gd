extends Node3D

@onready var cube_tournant: Node3D = $CubeTournant
@onready var j1: CharacterBody3D = $SplitScreens/Camera1/POV1/J1
@onready var j2: CharacterBody3D = $SplitScreens/Camera2/POV2/J2
@onready var pause_menu: ColorRect = $CubeTournant/HUD/PauseMenu

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("StopGame"):
		cube_tournant._onPartieTimerTimeout()
