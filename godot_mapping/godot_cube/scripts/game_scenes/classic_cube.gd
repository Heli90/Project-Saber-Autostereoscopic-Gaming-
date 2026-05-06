extends StaticBody3D

var vitesse_deplacement: float = 0.0
var nb_touches_j1: int = 0
var nb_touches_j2: int = 0

signal striked_cube_j1
signal missed_cube_j1
signal striked_cube_j2
signal missed_cube_j2

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(Vector3(0, 0, 1).normalized() * vitesse_deplacement * delta)
	# On supprime le cube s'il passe derrière l'un des joueurs
	if position.z > 20.0:
		emit_signal("missed_cube_j1")
		queue_free()
	elif position.z < -20.0:
		emit_signal("missed_cube_j2")
		queue_free()

	# On inverse le sens de déplacement du cube pour le renvoyer à l'autre joueur s'il a touché le cube
	if collision:
		vitesse_deplacement = -vitesse_deplacement
		if position.z > 0:
			emit_signal("striked_cube_j1")
		else:
			emit_signal("striked_cube_j2")
	
	# On supprime le cube s'il a déjà été touché une fois par les 2 joueurs
	if nb_touches_j1 == 1 and nb_touches_j2 == 1:
		queue_free()
