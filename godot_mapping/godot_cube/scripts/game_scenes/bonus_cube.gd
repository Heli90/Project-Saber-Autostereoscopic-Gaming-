extends StaticBody3D

var vitesse_deplacement: float = 0.0
var nb_touches_j1: int = 0
var nb_touches_j2: int = 0

signal striked_cube_j1
signal striked_cube_j2

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(Vector3(0, 0, 1).normalized() * vitesse_deplacement * delta)
	# On supprime le cube s'il passe derrière l'un des joueurs
	if abs(position.z) > 20.0:
		queue_free()

	# On supprime le cube et on apporte le bonus de cube s'il est touché par l'un des joueurs
	if collision:
		if position.z > 0:
			emit_signal("striked_cube_j1")
			queue_free()
		else:
			emit_signal("striked_cube_j2")
			queue_free()
