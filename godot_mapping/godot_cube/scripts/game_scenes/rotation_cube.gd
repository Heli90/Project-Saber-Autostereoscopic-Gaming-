extends AnimatableBody3D

@onready var landmarks_proceed = $"../LandMarksProceed"
@onready var time_stop_sound: AudioStreamPlayer = $"../../TimeStopSound"
@export var vitesse_rotation = 1.0

var facteur_rotation = 2.0

"""!-! TACHES FAITES A CHAQUE FRAME !-!"""
func _physics_process(delta: float) -> void:
	# Rotation du cube.
	# Prise en compte des FPS de l'ordinateur.
	if landmarks_proceed._maj_speed()[1]== "Closed_Fist" :
		#time_stop_sound.play()
		vitesse_rotation = 0
	else :
		vitesse_rotation = facteur_rotation*landmarks_proceed._maj_speed()[0]
	rotate_y(vitesse_rotation * delta)
