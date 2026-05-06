extends Node3D

@export var classic_bloc: PackedScene
@onready var start_label: Label = $"../StartLabel"
@onready var score_j1: Label = $"../ScoreJ1"
@onready var score_j2: Label = $"../ScoreJ2"

var start_spawn: bool = false

var elapsed_time: float = 0.0
var grille = [[0.0, 2.0], [-2.0, 2.0], [2.0, 2.0]]
var blocs: Array[Node3D]

var seuil: int = 5
var stocked_combo_j1: int = 0
var stocked_combo_j2: int = 0
var best_combo: int = 0

var multiplicateur_j1: int = 1
var multiplicateur_j2: int = 1
var current_score_j1: int = 0
var current_score_j2: int = 0
var vitesse_deplacement_cubes: float = 10.0

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
		if best_combo < stocked_combo_j1 or best_combo < stocked_combo_j2:
			best_combo = max(stocked_combo_j1, stocked_combo_j2)
		
		# Si un certain combo est atteint par l'un des 2 joueurs, on incrémente la vitesse
		if stocked_combo_j1 >= seuil or stocked_combo_j2 >= seuil:
			vitesse_deplacement_cubes *= 1.5
			set_speed()

		# Selon qui a incrémenté la vitesse, on incrémente son multiplicateur de score
		if stocked_combo_j1 >= seuil:
			multiplicateur_j1 *= 2
			seuil += 5
		elif stocked_combo_j2 >= seuil:
			multiplicateur_j2 *= 2
			seuil += 5

		if elapsed_time >= 5.0:
			elapsed_time -= 5.0
			generate_classic_bloc()

func case_valide(case: Array) -> bool:
	for bloc in blocs:
		if case == [bloc.position.x, bloc.position.y]: return false
	return true

func generate_classic_bloc():
	var new_bloc: Node3D = classic_bloc.instantiate()
	# On ajoute le bloc à la liste totale des blocs ainsi qu'à la scène pour qu'il soit bien là
	blocs.append(new_bloc)
	add_child(new_bloc)
	
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	new_bloc.striked_cube_j1.connect(_onStrikedCube_j1)
	new_bloc.missed_cube_j1.connect(_onMissedCube_j1)
	new_bloc.striked_cube_j2.connect(_onStrikedCube_j2)
	new_bloc.missed_cube_j2.connect(_onMissedCube_j2)

	# On filtre les coordonnées restantes pour ne pas avoir des cubes qui se superposent
	var coord_restantes = grille.filter(case_valide)
	if coord_restantes == []: return

	var coord = coord_restantes[randi() % coord_restantes.size()]
	new_bloc.position = Vector3(coord[0], coord[1], 0.0)
	new_bloc.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	new_bloc.vitesse_deplacement = vitesse_deplacement_cubes

func _onStrikedCube_j1() -> void:
	stocked_combo_j1 += 1
	current_score_j1 += multiplicateur_j1 * 10
	score_j1.text = "Score J1 : %d"%current_score_j1

func _onMissedCube_j1() -> void:
	multiplicateur_j1 = 1
	stocked_combo_j1 = 0
	vitesse_deplacement_cubes = 10.0

func _onStrikedCube_j2() -> void:
	stocked_combo_j2 += 1
	current_score_j2 += multiplicateur_j2 * 10
	score_j2.text = "Score J2 : %d"%current_score_j2

func _onMissedCube_j2() -> void:
	multiplicateur_j1 = 1
	stocked_combo_j2 = 0
	vitesse_deplacement_cubes = 10.0
