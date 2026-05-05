extends Node3D

@export var classic_bloc: PackedScene
@onready var start_label: Label = $"../StartLabel"

var start_spawn: bool = false

var elapsed_time: float = 0.0
var grille = [[0.0, 2.0], [-2.0, 2.0], [2.0, 2.0]]
var blocs: Array[Node3D]
var seuil: int = 5
var total_combo: int = 0
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

func _process(delta: float) -> void:
	if start_spawn:
		elapsed_time += delta
		# On retire les blocs qui ont été supprimés du jeu
		blocs = blocs.filter(func(bloc): return is_instance_valid(bloc))
		if blocs == []:
			generate_classic_bloc()
			vitesse_deplacement_cubes = 10.0
			seuil = 5

		# On actualise le meilleur combo de cubes
		total_combo = 0
		for bloc in blocs:
			total_combo += bloc.nb_touches
		if total_combo >= seuil:
			vitesse_deplacement_cubes *= 1.5
			seuil += 5
			for bloc in blocs:
				if bloc.vitesse_deplacement > 0: bloc.vitesse_deplacement = vitesse_deplacement_cubes
				else: bloc.vitesse_deplacement = -vitesse_deplacement_cubes

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

	# On filtre les coordonnées restantes pour ne pas avoir des cubes qui se superposent
	var coord_restantes = grille.filter(case_valide)
	var coord = coord_restantes[randi() % coord_restantes.size()]
	new_bloc.position = Vector3(coord[0], coord[1], 0.0)
	new_bloc.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	new_bloc.vitesse_deplacement = vitesse_deplacement_cubes
