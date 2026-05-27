extends StaticBody3D

var vitesse_deplacement: float = 0.0
var all_meshes: Array[Node]

# Variables associées au fade-in, au fade-out et sa durée
var fading_in: bool = false
var fading_out: bool = false
var fade_duration: float = 0.25
var elapsed_fade_in: float = 0.0
var elapsed_fade_out: float = 0.0

signal striked_cube_j1
signal striked_cube_j2

func _ready() -> void:
	all_meshes = find_children("*", "", true, false)
	for mesh in all_meshes:
		var mat: Material
		match mesh:
			CollisionShape3D: pass
			MeshInstance3D:
				mesh.mesh = mesh.mesh.duplicate()
				mat = mesh.get_active_material(0)
			CSGPolygon3D:
				mat = mesh.material
		if mat:
			mat = mat.duplicate()
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = 0.0
			mesh.set_surface_override_material(0, mat)
	fading_in = true
	# On lance le clignotement en parallèle
	await clignote()
	# Après le clignotement, le cube devient invisible mais reste actif
	for forme in all_meshes:
		forme.visible = false
	add_to_group("cube")

func clignote() -> void:
	await get_tree().create_timer(1.0).timeout
	for i in range(3):
		visible = false
		await get_tree().create_timer(0.2).timeout
		visible = true
		await get_tree().create_timer(0.2).timeout

func _process(delta: float) -> void:
	# On fait le fade-in si nécessaire
	if fading_in:
		elapsed_fade_in += delta
		set_all_alpha(elapsed_fade_in / fade_duration)
		if elapsed_fade_in >= fade_duration:
			set_all_alpha(1.0)
			fading_in = false
			elapsed_fade_in = 0.0

	# On fait le fade-out si nécessaire
	if fading_out:
		elapsed_fade_out += delta
		set_all_alpha(1.0 - (elapsed_fade_out / fade_duration))
		if elapsed_fade_out >= fade_duration:
			queue_free()

func _physics_process(delta: float) -> void:
	# On retourne le cube pour qu'il ait la bonne face pour le joueur qui la reçoit
	if vitesse_deplacement < 0:
		rotation.y = TAU/2
	else:
		rotation.y = 0

	move_and_collide(Vector3(0, 0, 1).normalized() * vitesse_deplacement * delta)
	# On supprime le cube s'il passe derrière l'un des joueurs
	if abs(position.z) > 22.5:
		start_fade_out()

func set_all_alpha(alpha: float) -> void:
	for mesh in all_meshes:
		var mat: Material
		match mesh:
			CollisionShape3D: pass
			MeshInstance3D:
				mesh.mesh = mesh.mesh.duplicate()
				mat = mesh.get_active_material(0)
			CSGPolygon3D:
				mat = mesh.material
		if mat:
			mat.albedo_color.a = clamp(alpha, 0.0, 1.0)

func start_fade_out() -> void:
	if fading_out: return
	fading_out = true
	elapsed_fade_out = 0.0
	set_all_alpha(0.0)

# On supprime le cube et on apporte le bonus de cube s'il est touché par l'un des joueurs
func collision() -> void:
		if position.z > 0:
			emit_signal("striked_cube_j1")
			start_fade_out()
		else:
			emit_signal("striked_cube_j2")
			start_fade_out()
