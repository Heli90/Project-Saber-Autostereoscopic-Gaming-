extends StaticBody3D

@export var particles_vfx: PackedScene
var vitesse_deplacement: float = 0.0

signal striked_cube_j1(bloc)
signal striked_cube_j2(bloc)

func _ready() -> void:
	# On attend 1 seconde puis on lance le clignotement
	await get_tree().create_timer(1.0).timeout
	await _clignote()
	# Après le clignotement, le cube devient invisible mais reste actif
	visible = false
	add_to_group("cube")

func _clignote() -> void:
	for i in range(3):
		visible = false
		await get_tree().create_timer(0.2).timeout
		visible = true
		await get_tree().create_timer(0.2).timeout

func _physics_process(delta: float) -> void:
	# On retourne le cube pour qu'il ait la bonne face pour le joueur qui la reçoit
	if vitesse_deplacement < 0: rotation.y = TAU/2
	else: rotation.y = 0

	move_and_collide(Vector3(0, 0, 1).normalized() * vitesse_deplacement * delta)
	# On supprime le cube s'il passe derrière l'un des joueurs
	if position.z > 20.0: queue_free()
	elif position.z < -20.0:
		if Global.two_player_mode: queue_free()
		else: collision()

	# On supprime le cube et on apporte le bonus de cube s'il est touché par l'un des joueurs
func collision() -> void:
	HitCubeSound.play()
	apply_vfx()
	if position.z > 0: emit_signal("striked_cube_j1", self)
	else: emit_signal("striked_cube_j2", self)

func apply_vfx() -> void:
	if particles_vfx == null: return
	var particles_instance = particles_vfx.instantiate()
	get_parent().add_child(particles_instance)
	particles_instance.global_position = global_position

	for child in particles_instance.get_children():
		if child is GPUParticles3D: child.emitting = true

	# On détruit les particules après leur durée de vie
	var max_lifetime = 0.0
	for child in particles_instance.get_children():
		if child is GPUParticles3D: max_lifetime = max(max_lifetime, child.lifetime)

	await get_tree().create_timer(max_lifetime + 0.5).timeout
	if is_instance_valid(particles_instance): particles_instance.queue_free()
