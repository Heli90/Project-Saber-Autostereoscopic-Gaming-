extends AnimatableBody3D

@export var vitesse_rotation = 1

"""!-! TACHES FAITES A CHAQUE FRAME !-!"""
func _physics_process(delta: float) -> void:
	# Rotation du cube.
	# Prise en compte des FPS de l'ordinateur.
	rotate_y(vitesse_rotation * delta)
