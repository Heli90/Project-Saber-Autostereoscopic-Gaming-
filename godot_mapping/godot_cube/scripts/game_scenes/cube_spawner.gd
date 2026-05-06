extends Node3D

@export var classic_bloc: PackedScene
@export var bonus_bloc: PackedScene
@onready var start_label: Label = $"../StartLabel"
@onready var score_j1: Label = $"../ScoreJ1"
@onready var score_j2: Label = $"../ScoreJ2"

# Booléen de départ pour lancer l'apparition des cubes après le message de départ
var start_spawn: bool = false

var vitesse_deplacement_cubes: float = 10.0
var direction_rng = RandomNumberGenerator.new()

# Temps de jeu écoulé et temps de seuil pseudo-aléatoire via une variable RNG
var elapsed_time: float = 0.0
var time_rng = RandomNumberGenerator.new()
var threshold_time: float = time_rng.randf_range(3.0, 10.0)

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
var current_score: Array[int] = [0, 0]

# Fonction appelée par le script du jeu pour démarrer l'apparition des cubes
func activation() -> void:
	start_spawn = true
	start_game()

func start_game() -> void:
	start_label.text = "GO !"
	generate_classic_bloc()
	var transition = create_tween()
	transition.tween_property(start_label, "modulate:a", 0.0, 0.5)
	await transition.finished
	start_label.visible = false

func set_speed() -> void:
	for bloc in blocs:
		if bloc.vitesse_deplacement > 0: bloc.vitesse_deplacement = vitesse_deplacement_cubes
		else: bloc.vitesse_deplacement = -vitesse_deplacement_cubes

func _process(delta: float) -> void:
	if start_spawn:
		elapsed_time += delta

		# On retire les blocs qui ont été supprimés du jeu
		blocs = blocs.filter(func(bloc): return is_instance_valid(bloc))
		set_speed()
		if blocs == []:
			generate_classic_bloc()
			seuil = 5

		# On actualise le meilleur combo de cubes
		if best_combo < stocked_combo.max():
			best_combo = stocked_combo.max()

		# Si un certain combo est atteint par l'un des 2 joueurs, on incrémente la vitesse
		if stocked_combo.min() >= seuil:
			vitesse_deplacement_cubes *= 1.5
			set_speed()

		# Selon qui a incrémenté la vitesse, on incrémente son multiplicateur de score
		for i in range(2):
			if stocked_combo[i] >= seuil:
				multiplicateur[i] *= 2
				combo_sucess = true
		if combo_sucess: seuil += 5
		
		# On fait apparaître un bloc bonus à chaque fois que le temps de seuil est dépassé
		if elapsed_time >= threshold_time:
			elapsed_time -= threshold_time
			threshold_time = time_rng.randf_range(3.0, 10.0)
			generate_bonus_bloc()
		
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

func spawn_valide(bloc: Node3D) -> void:
	# On filtre les coordonnées restantes pour ne pas avoir des cubes qui se superposent
	var coord_restantes = grille.filter(case_valide)
	if coord_restantes == []: return

	var coord = coord_restantes[randi() % coord_restantes.size()]
	bloc.position = Vector3(coord[0], coord[1], 0.0)
	bloc.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	
	var direction_cube = direction_rng.randi_range(0, 1)
	if direction_cube == 0: bloc.vitesse_deplacement = vitesse_deplacement_cubes
	else: bloc.vitesse_deplacement = -vitesse_deplacement_cubes

func generate_classic_bloc():
	var new_bloc = generate_bloc(classic_bloc)

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

func StrikedClassicCube(i: int) -> void:
	stocked_combo[i] += 1
	current_score[i] += multiplicateur[i] * 1000
	if i == 0: score_j1.text = "Score J1 : %d"%current_score[i]
	else: score_j2.text = "Score J2 : %d"%current_score[i]

func MissedClassicCube(i: int) -> void:
	multiplicateur[i] = 1
	stocked_combo[i] = 0
	vitesse_deplacement_cubes = 10.0

func StrikedBonusCube(i: int) -> void:
	stocked_combo[i] += 1
	current_score[i] += multiplicateur[i] * 5000
	multiplicateur[i] *= 2
	count_bonus_time[i] = true
	if i == 0: score_j1.text = "Score J1 : %d"%current_score[i]
	else: score_j2.text = "Score J2 : %d"%current_score[i]

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
