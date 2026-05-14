extends Node3D

@onready var jeu: Node3D = $Game
@onready var j1: Node3D = $SplitScreens/Camera1/POV1/J1
@onready var j2: Node3D = $SplitScreens/Camera2/POV2/J2
@onready var pause_menu: ColorRect = $Game/HUD/PauseMenu
@onready var ink_layer_j1: CanvasLayer = $Game/HUD/InkLayerJ1
@onready var ink_layer_j2: CanvasLayer = $Game/HUD/InkLayerJ2

func _ready() -> void:
	ink_layer_j1.custom_viewport = get_node("SplitScreens/Camera1/POV1")
	ink_layer_j2.custom_viewport = get_node("SplitScreens/Camera2/POV2")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("StopGame"):
		jeu._onPartieTimerTimeout()
