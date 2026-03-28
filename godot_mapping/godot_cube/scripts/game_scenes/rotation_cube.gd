extends AnimatableBody3D

@onready var landmarks_proceed = $".."/LandMarksProceed

@export var vitesse_rotation = 1.0

var facteur_rotation = 2.0

"""!-! TACHES FAITES A CHAQUE FRAME !-!"""
func _physics_process(delta: float) -> void:
	# Rotation du cube.
	# Prise en compte des FPS de l'ordinateur.
	vitesse_rotation = facteur_rotation*landmarks_proceed._maj_speed()
	rotate_y(vitesse_rotation * delta)
