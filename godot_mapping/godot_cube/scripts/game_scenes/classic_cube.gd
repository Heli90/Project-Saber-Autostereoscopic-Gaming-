extends StaticBody3D

@onready var forme_cube: MeshInstance3D = $MeshInstance3D
var vitesse_deplacement: float = 0.0

# Couleur représentée par un entier pour déterminer le nombre de coups nécessaires pour supprimer le cube
var color: int = 1
var setup_color: bool = false

# Temps minimal imposé entre 2 collisions pour éviter d'appliquer 2 fois l'algorithme
# de collision lorsque les 2 sabres du joueur frappent en même temps le cube
var time_collision: float = 0.25
var elapsed_time_since_collision: float = 0.0
var nb_collisions: int = 0

signal striked_cube_j1
signal missed_cube_j1
signal striked_cube_j2
signal missed_cube_j2

func _ready() -> void:
	# On duplique le matériau pour pouvoir modifier la couleur de ce cube uniquement
	forme_cube.mesh = forme_cube.mesh.duplicate()
	forme_cube.visible = false
	add_to_group("cube")

func _process(delta) -> void:
	# On met en place la couleur du cube si nécessaire
	if setup_color:
		var mat = forme_cube.get_active_material(0)
		match color:
			1: mat.albedo_color = Color(1.0, 0.0, 0.0, 1.0)
			2: mat.albedo_color = Color(1.0, 0.431, 0.196, 1.0)
			3: mat.albedo_color = Color(0.0, 1.0, 0.0, 1.0)
		forme_cube.visible = true
		setup_color = false
	
	# On met à jour le temps depuis qu'il y a eu une collision si nécessaire
	if nb_collisions >= 1:
		elapsed_time_since_collision += delta
		if elapsed_time_since_collision > time_collision:
			nb_collisions = 0
			elapsed_time_since_collision = 0.0

func _physics_process(delta: float) -> void:
	# On supprime le cube s'il a déjà été touché autant de fois que la couleur l'indique
	if color == 0:
		queue_free()

	move_and_collide(Vector3(0, 0, 1).normalized() * vitesse_deplacement * delta)
	# On supprime le cube s'il passe derrière l'un des joueurs
	if position.z > 20.0:
		emit_signal("missed_cube_j1")
		queue_free()
	elif position.z < -20.0:
		emit_signal("missed_cube_j2")
		queue_free()

# On inverse le sens de déplacement du cube pour le renvoyer à l'autre joueur s'il a touché le cube
func collision() -> void:
	# On change la couleur du cube et on augmente légèrement la vitesse
	nb_collisions += 1
	if nb_collisions == 1 :
		color -= 1
		setup_color = true
		vitesse_deplacement *= 1.10
		# On change ensuite la direction du cube
		vitesse_deplacement = -vitesse_deplacement
		if position.z > 0:
			emit_signal("striked_cube_j1")
		else:
			emit_signal("striked_cube_j2")
