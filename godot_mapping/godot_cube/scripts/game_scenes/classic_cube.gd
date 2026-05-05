extends StaticBody3D

var vitesse_deplacement: float = 0.0
var nb_touches: int = 0

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(Vector3(0, 0, 1).normalized() * vitesse_deplacement * delta)
	# On supprime le cube s'il passe derrière l'un des joueurs
	if abs(position.z) > 20.0:
		queue_free()

	# On inverse le sens de déplacement du cube pour le renvoyer à l'autre joueur s'il a touché le cube
	if collision:
		vitesse_deplacement = -vitesse_deplacement
		nb_touches += 1
