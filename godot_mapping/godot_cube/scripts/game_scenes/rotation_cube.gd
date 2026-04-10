extends AnimatableBody3D

@onready var landmarks_proceed = $"../LandMarksProceed"
@onready var time_stop_sound: AudioStreamPlayer = $"../TimeStopSound"
@export var vitesse_rotation = 1.0

var facteur_rotation = 2.0
var last_gesture = ""

var cnt = 0 #TESTS
var vect = Vector3.FORWARD # TESTS

"""!-! TACHES FAITES A CHAQUE FRAME !-!"""
func _physics_process(delta: float) -> void:
	# Rotation du cube.
	# Prise en compte des FPS de l'ordinateur.
	if landmarks_proceed._maj_speed()[1] == "Closed_Fist" :
		if last_gesture != "Closed_Fist" :
			last_gesture = "Closed_Fist"
			time_stop_sound.play()
		vitesse_rotation = 0
	else :
		last_gesture = ""
		vitesse_rotation = facteur_rotation*landmarks_proceed._maj_speed()[0]
	rotate_y(vitesse_rotation * delta)
	
	"""Cube qui bouge pour tester l'inversion de profondeur"""
	if cnt>500 and vect == Vector3.FORWARD:
		vect = Vector3.BACK
		cnt = 0
	elif cnt>500 and vect == Vector3.BACK:
		vect = Vector3.FORWARD
		cnt = 0
	cnt = cnt + 1
	translate(vect * 0.1)
	
	
