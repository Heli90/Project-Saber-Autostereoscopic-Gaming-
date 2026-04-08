extends Node3D

@onready var cube_tournant: Node3D = $CubeTournant
@onready var j1: CharacterBody3D = $SplitScreens/Camera1/POV1/J1
@onready var j2: CharacterBody3D = $SplitScreens/Camera2/POV2/J2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("StopGame"):
		cube_tournant._onPartieTimerTimeout()

func _process(_delta: float) -> void:
	# Téléportation en zone de test
	if j1.position.z > 40.0:
		j1.position = Vector3(-4.0, 0.0, 4.0)
	if j2.position.z > 40.0:
		j2.position = Vector3(4.0, 0.0, 4.0)
	# Téléportation hors de la zone de test
	elif (abs(j1.position.z) > 10.0 and abs(j1.position.x) < 6.0) or (5.0 < abs(j1.position.x) and abs(j1.position.x) < 8.0):
		j1.position = Vector3(-10.0, 1.0, 35.0)
	elif (abs(j2.position.z) > 10.0 and abs(j2.position.x) < 6.0) or (5.0 < abs(j2.position.x) and abs(j2.position.x) < 8.0):
		j2.position = Vector3(-10.0, 1.0, 35.0)
		
