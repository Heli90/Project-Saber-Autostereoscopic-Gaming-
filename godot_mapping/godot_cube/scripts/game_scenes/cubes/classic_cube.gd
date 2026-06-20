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

# Variables associées au spin et sa durée
var spin: bool = false
var time_spin: float = 0.5
var elapsed_time_since_spin: float = 0.0

# Variables associées au fade-in, au fade-out et sa durée
var fading_in: bool = false
var fading_out: bool = false
var fade_duration: float = 0.25
var elapsed_fade_in: float = 0.0
var elapsed_fade_out: float = 0.0

signal striked_cube_j1
signal missed_cube_j1
signal striked_cube_j2
signal missed_cube_j2

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	# On duplique le matériau pour pouvoir modifier la couleur de ce cube uniquement
	forme_cube.mesh = forme_cube.mesh.duplicate()
	var mat = forme_cube.get_active_material(0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.0
	forme_cube.visible = false
	add_to_group("cube")

func _process(delta) -> void:
	# On met en place la couleur du cube si nécessaire
	if setup_color:
		var mat = forme_cube.get_active_material(0)
		match color:
			1: mat.albedo_color = Color("d00040")
			2: mat.albedo_color = Color("ff7e0b")
			3: mat.albedo_color = Color("43975d")
		mat.albedo_color.a = 0.0
		forme_cube.visible = true
		setup_color = false
		fading_in = true
	
	# On met à jour le temps depuis qu'il y a eu une collision si nécessaire
	if nb_collisions >= 1:
		elapsed_time_since_collision += delta
		if elapsed_time_since_collision > time_collision:
			nb_collisions = 0
			elapsed_time_since_collision = 0.0
	
	# On fait le fade-in si nécessaire
	if fading_in:
		elapsed_fade_in += delta
		var alpha = elapsed_fade_in / fade_duration
		var mat = forme_cube.get_active_material(0)
		mat.albedo_color.a = clamp(alpha, 0.0, 1.0)
		if elapsed_fade_in >= fade_duration:
			mat.albedo_color.a = 1.0
			fading_in = false
			elapsed_fade_in = 0.0

	# On fait le fade-out si nécessaire
	if fading_out:
		elapsed_fade_out += delta
		var alpha = 1.0 - (elapsed_fade_out / fade_duration)
		var mat = forme_cube.get_active_material(0)
		mat.albedo_color.a = clamp(alpha, 0.0, 1.0)
		if elapsed_fade_out >= fade_duration:
			queue_free()

func _physics_process(delta: float) -> void:
	# On supprime le cube s'il a déjà été touché autant de fois que la couleur l'indique
	if color == 0:
		start_fade_out()
	
	if not fading_out:
		# On retourne le cube pour qu'il ait la bonne face pour le joueur qui la reçoit
		if vitesse_deplacement < 0:
			rotation.y = TAU/2
		else:
			rotation.y = 0

		move_and_collide(Vector3(0, 0, 1).normalized() * vitesse_deplacement * delta)
		# On supprime le cube s'il passe derrière l'un des joueurs
		if position.z > 22.5:
			emit_signal("missed_cube_j1")
			start_fade_out()
		elif position.z < -22.5:
			emit_signal("missed_cube_j2")
			start_fade_out()
	
		if spin:
			elapsed_time_since_spin += delta
			var spin_speed = TAU / time_spin
			rotation.x += spin_speed * delta
			if elapsed_time_since_spin > time_spin:
				# On arrondit au multiple de π le plus proche (180°)
				var half_turns = round(rotation.x / PI)
				rotation.x = half_turns * PI
				elapsed_time_since_spin = 0.0
				spin = false

func start_fade_out() -> void:
	if fading_out: return
	fading_out = true
	elapsed_fade_out = 0.0
	
	# On active la transparence sur le matériau
	var mat = forme_cube.get_active_material(0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

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
		spin = true
		if position.z > 0:
			emit_signal("striked_cube_j1")
		else:
			emit_signal("striked_cube_j2")
