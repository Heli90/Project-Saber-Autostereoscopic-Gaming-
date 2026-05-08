extends Node3D

@export var classic_bloc: PackedScene
@export var bonus_bloc: PackedScene
@export var bomb_bloc: PackedScene
@export var disappear_bloc: PackedScene
@onready var start_label: Label = $"../StartLabel"
@onready var disappear_bloc_notif: Label = $"../DisappearBlocNotif"

# Booléen de départ pour lancer l'apparition des cubes après le message de départ
var start_spawn: bool = false
# Générateur aléatoire de nombres pour tous les tirages aléatoires
var rng = RandomNumberGenerator.new()

# Temps de jeu écoulé et temps de seuil pseudo-aléatoire via une variable RNG
var elapsed_time: float = 0.0
var threshold_time: float = rng.randf_range(3.0, 10.0)

# Temps pendant lesquels chacun des joueurs aura son bonus de multiplicateur (x2)
var bonus_time: Array[float] = [0.0, 0.0]
var count_bonus_time: Array[bool] = [false, false]

# Grille de jeu où vont apparaître les cubes
var grille = [[0.0, 2.0], [-2.0, 2.0], [2.0, 2.0]]
# Stockage des différents blocs du terrain
var blocs: Array[Node3D]

# Variables liées aux combos
var seuil: int = 5
var stocked_combo: Array[int] = [0, 0]
var best_combo: int = 0
var combo_sucess: bool = false

# Multiplicateurs de score et scores actuels pour chaque joueur
var multiplicateur: Array[int] = [1, 1]

# Scores visuels des joueurs
var score_uis : Array = []
var j1: Node3D
var j2: Node3D

# Fonction appelée par le script du jeu pour démarrer l'apparition des cubes et charger les scores visuels
func activation() -> void:
	j1 = get_node_or_null("../../SplitScreens/Camera1/POV1/J1")
	j2 = get_node_or_null("../../SplitScreens/Camera2/POV2/J2")
	if not j1 and not j2:
		j1 = get_node_or_null("../../J1")
		j2 = get_node_or_null("../../J2")
	if j1: score_uis.append(j1.score_ui)
	if j2: score_uis.append(j2.score_ui)
	start_spawn = true
	start_game()

func start_game() -> void:
	start_label.text = "GO !"
	generate_classic_bloc()
	var transition = create_tween()
	transition.tween_property(start_label, "modulate:a", 0.0, 0.5)
	await transition.finished
	start_label.visible = false

func set_speed(bloc: Node3D, direction: int, disappear: bool) -> void:
	match disappear:
		false: match direction:
				0: bloc.vitesse_deplacement = rng.randf_range(5.0, 10.0)
				1: bloc.vitesse_deplacement = rng.randf_range(-5.0, -10.0)
		true: match direction:
				0: bloc.vitesse_deplacement = rng.randf_range(4.0, 6.0)
				1: bloc.vitesse_deplacement = rng.randf_range(-4.0, -6.0)

# Multiplie la vitesse de tous les blocs de 25% quand un palier de combo est dépassé
func increment_speed(bloc: Node3D) -> void:
	bloc.vitesse_deplacement *= 1.25

func _process(delta: float) -> void:
	if start_spawn:
		elapsed_time += delta

		# On retire les blocs qui ont été supprimés du jeu
		blocs = blocs.filter(func(bloc): return is_instance_valid(bloc))
		if blocs == []:
			generate_classic_bloc()
			seuil = 5

		# On actualise le meilleur combo de cubes
		if best_combo < stocked_combo.max():
			best_combo = stocked_combo.max()

		# Si un certain combo est atteint par l'un des 2 joueurs, on incrémente la vitesse
		if stocked_combo.min() >= seuil:
			for bloc in blocs : increment_speed(bloc)

		# Selon qui a incrémenté la vitesse, on incrémente son multiplicateur de score
		for i in range(2):
			if stocked_combo[i] >= seuil:
				multiplicateur[i] *= 2
				combo_sucess = true
		if combo_sucess: seuil += 5
		
		# On fait apparaître un bloc bonus à chaque fois que le temps de seuil est dépassé
		if elapsed_time >= threshold_time:
			elapsed_time -= threshold_time
			threshold_time = rng.randf_range(3.0, 10.0)
			generate_bomb_bloc()
		
		# On calcule le temps de bonus pour chacun des 2 joueurs et on arrête le bonus une fois que ce temps est dépassé
		for i in range(2):
			if count_bonus_time[i]:
				bonus_time[i] += delta
		for i in range(2):
			if bonus_time[i] >= 10.0 and multiplicateur[i] > 1:
				multiplicateur[i] /= 2

func generate_bloc(scene_bloc: PackedScene) -> Node3D:
	var new_bloc: Node3D = scene_bloc.instantiate()
	blocs.append(new_bloc)
	add_child(new_bloc)
	return new_bloc

func case_valide(case: Array) -> bool:
	for bloc in blocs:
		if case == [bloc.position.x, bloc.position.y]: return false
	return true

func spawn_valide(bloc: Node3D, disappear: bool = false) -> void:
	# On filtre les coordonnées restantes pour ne pas avoir des cubes qui se superposent
	var coord_restantes = grille.filter(case_valide)
	if coord_restantes == []: return

	var coord = coord_restantes[randi() % coord_restantes.size()]
	bloc.position = Vector3(coord[0], coord[1], 0.0)
	bloc.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	
	var direction_cube = rng.randi_range(0, 1)
	set_speed(bloc, direction_cube, disappear)

func generate_classic_bloc():
	var new_bloc = generate_bloc(classic_bloc)
	
	# On initialise de façon aléatoire la couleur du bloc
	new_bloc.color = rng.randi_range(1, 3)
	new_bloc.setup_color = true

	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	new_bloc.striked_cube_j1.connect(_onStrikedClassicCube_j1)
	new_bloc.missed_cube_j1.connect(_onMissedClassicCube_j1)
	new_bloc.striked_cube_j2.connect(_onStrikedClassicCube_j2)
	new_bloc.missed_cube_j2.connect(_onMissedClassicCube_j2)
	spawn_valide(new_bloc)

func generate_bonus_bloc() -> void:
	var new_bloc = generate_bloc(bonus_bloc)
	
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	new_bloc.striked_cube_j1.connect(_onStrikedBonusCube_j1)
	new_bloc.striked_cube_j2.connect(_onStrikedBonusCube_j2)
	spawn_valide(new_bloc)

func generate_bomb_bloc() -> void:
	var new_bloc = generate_bloc(bomb_bloc)
	
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	new_bloc.striked_cube_j1.connect(_onStrikedBombCube_j1)
	new_bloc.striked_cube_j2.connect(_onStrikedBombCube_j2)
	spawn_valide(new_bloc)

func generate_disappear_bloc() -> void:
	var new_bloc = generate_bloc(disappear_bloc)
	
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	new_bloc.striked_cube_j1.connect(_onStrikedDisappearCube_j1)
	new_bloc.striked_cube_j2.connect(_onStrikedDisappearCube_j2)
	spawn_valide(new_bloc, true)

func StrikedClassicCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 1000
	score_uis[i].ajouter_score(gain)

func MissedClassicCube(i: int) -> void:
	multiplicateur[i] = 1
	stocked_combo[i] = 0

func StrikedBonusCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 5000
	multiplicateur[i] *= 2
	count_bonus_time[i] = true
	score_uis[i].ajouter_score(gain)

func StrikedBombCube(i: int) -> void:
	stocked_combo[i] = 0
	var gain = -500
	multiplicateur[i] = 1
	score_uis[i].ajouter_score(gain)

func StrikedDisappearCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 15000
	multiplicateur[i] *= 2
	score_uis[i].ajouter_score(gain)
	disappear_bloc_notif.visible = true
	await get_tree().create_timer(1.0).timeout
	disappear_bloc_notif.visible = false

func _onStrikedClassicCube_j1() -> void:
	StrikedClassicCube(0)

func _onMissedClassicCube_j1() -> void:
	MissedClassicCube(0)

func _onStrikedClassicCube_j2() -> void:
	StrikedClassicCube(1)

func _onMissedClassicCube_j2() -> void:
	MissedClassicCube(1)

func _onStrikedBonusCube_j1() -> void:
	StrikedBonusCube(0)

func _onStrikedBonusCube_j2() -> void:
	StrikedBonusCube(1)

func _onStrikedBombCube_j1() -> void:
	StrikedBombCube(0)

func _onStrikedBombCube_j2() -> void:
	StrikedBombCube(1)

func _onStrikedDisappearCube_j1() -> void:
	StrikedDisappearCube(0)

func _onStrikedDisappearCube_j2() -> void:
	StrikedDisappearCube(1)
