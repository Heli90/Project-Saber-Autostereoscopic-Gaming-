extends AnimatableBody3D

@onready var landmarks_proceed = $"../LandMarksProceed"
@onready var time_stop_sound: AudioStreamPlayer = $"../TimeStopSound"
@export var vitesse_rotation = 1.0
@onready var test_label: Label = $"../TestLabel"

var facteur_rotation = 2.0
var last_gesture = ""

"""!-! TACHES FAITES A CHAQUE FRAME !-!"""
func _physics_process(delta: float) -> void:
	# Rotation du cube.
	# Prise en compte des FPS de l'ordinateur.
	if landmarks_proceed._maj_speed()[1] == "Closed_Fist" :
		if last_gesture != "Closed_Fist" :
			last_gesture = "Closed_Fist"
			time_stop_sound.play()
			test_label.text = "ZA WARUDO"
		vitesse_rotation = 0
	else :
		last_gesture = ""
		vitesse_rotation = facteur_rotation*landmarks_proceed._maj_speed()[0]
		test_label.text = ""
	rotate_y(vitesse_rotation * delta)
