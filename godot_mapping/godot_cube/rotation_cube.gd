extends AnimatableBody3D

@export var vitesse_rotation = 5.0
@export var perso: Node3D 
@export var distance_cube = 3.0

var commande_bras_left = false
var commande_bras_right = false

"""!-! TACHES FAITES A CHAQUE FRAME !-!"""
func _process(delta: float) -> void:
	# Rotation du cube en cas de condition satisfaite.
	# Prise en compte des FPS de l'ordinateur.
	if commande_bras_left:
		rotate_y(vitesse_rotation * delta)
	elif commande_bras_right:
		rotate_z(vitesse_rotation * delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Contrôle du bras gauche"):
		commande_bras_left = true
	elif event.is_action_pressed("Contrôle du bras droit"):
		commande_bras_right = true
	elif event.is_action_released("Contrôle du bras gauche"):
		commande_bras_left = false
	elif event.is_action_released("Contrôle du bras droit"):
		commande_bras_right = false
