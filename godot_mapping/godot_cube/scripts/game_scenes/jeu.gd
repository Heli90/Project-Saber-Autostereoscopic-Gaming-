extends Node3D

@onready var fondu_noir: ColorRect = $HUD/FonduLayer/FonduNoir
@onready var partie_timer: Timer = $PartieTimer
@onready var game_ending: ColorRect = $HUD/GameEnding
@onready var cube_spawner: Node3D = $CubeSpawner
@onready var disappear_bloc_notif: Label = $DisappearBlocNotif

var level_music: AudioStreamPlayer
var pause_blocs : bool = false
const LEADERBOARD_PATH = "user://leaderboard.cfg"

func _ready() -> void:
	print(ProjectSettings.globalize_path("user://"))

	game_ending.visible = false
	game_ending.modulate.a = 0.0
	disappear_bloc_notif.visible = false

	var transition = create_tween()
	transition.tween_property(fondu_noir, "modulate:a", 0.0, 0.6)
	await transition.finished
	fondu_noir.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cube_spawner.activation()
	if Global.launched_mode == 2: partie_timer.start()

func set_blur_intensity(value: float):
	game_ending.material.set_shader_parameter("lod", value)

func _process(_delta: float) -> void:
	if Global.launched_mode == 2:
		# On vérifie si un des joueurs a perdu tous ses points de vie
		if cube_spawner.health[0] == 0:
			if cube_spawner.health[1] == 0:
				onPartieTimerTimeout()
			else:
				onPartieTimerTimeout(true, 2)
		elif cube_spawner.health[1] == 0:
			onPartieTimerTimeout(true, 1)
		if not level_music: level_music = get_node("../LevelMusic")
		if (not level_music.playing) and cube_spawner.is_generated and cube_spawner.elapsed_time > 5.0: onPartieTimerTimeout()

func onPartieTimerTimeout(death: bool = false, winner: int = 1) -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = true

	# On charge les scores de chacun des joueurs et on les affiche dans le classement
	var score_j1 = int(cube_spawner.score_uis[0].score.text)
	var score_j2 = int(cube_spawner.score_uis[1].score.text)
	
	# Si un des joueurs a perdu tous ses points de vie, son score n'est pas enregistré
	if death: match winner:
		1: save_scores_to_leaderboard(0, score_j2)
		2: save_scores_to_leaderboard(score_j1, 0)
	else: save_scores_to_leaderboard(score_j1, score_j2)
	afficher_leaderboard(load_leaderboard())
	
	var config = ConfigFile.new()
	config.load(LEADERBOARD_PATH)
	
	# Si un joueur a perdu tous ses points de vie, l'autre joueur gagne la partie
	if death: game_ending.best_player_text.text = config.get_value("Joueurs", "Nom_J%d"%(winner), "Joueur %d"%(winner))
	if score_j1 > score_j2:
		game_ending.best_player_text.text = config.get_value("Joueurs", "Nom_J1", "Joueur 1")
	elif score_j2 > score_j1:
		game_ending.best_player_text.text = config.get_value("Joueurs", "Nom_J2", "Joueur 2")
	else:
		game_ending.best_player_message.text = "It is a tie !"

	game_ending.visible = true
	var transition = create_tween().set_parallel(true)
	transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	transition.parallel().tween_property(game_ending, "modulate:a", 1.0, 0.3)
	transition.parallel().tween_method(set_blur_intensity, 0.0, 2.0, 0.3)
	await transition.finished
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func save_scores_to_leaderboard(score_j1: int, score_j2: int) -> void:
	var config = ConfigFile.new()
	config.load(LEADERBOARD_PATH)
	
	# Récupération des noms sauvegardés
	var nom1 = config.get_value("Joueurs", "Nom_J1", "Joueur 1")
	var nom2 = config.get_value("Joueurs", "Nom_J2", "Joueur 2")
	
	# Chargement des entrées existantes
	var entrees = config.get_value("Leaderboard", "Entrees", [])
	
	# Ajout des nouvelles entrées
	entrees.append({"nom": nom1, "score": score_j1})
	entrees.append({"nom": nom2, "score": score_j2})
	
	# On conserve le meilleur score associé à chaque joueur enregistré
	var dict: Dictionary = {}
	for e in entrees:
		if (not dict.has(e["nom"]) or e["score"] > dict[e["nom"]]) and e["nom"] not in ["Joueur 1", "Joueur 2"]:
			dict[e["nom"]] = e["score"]
	
	# Reconstruction du tableau à partir du dictionnaire
	entrees = []
	for nom in dict: entrees.append({"nom": nom, "score": dict[nom]})

	# Tri par score décroissant et on garde les 10 meilleurs scores
	entrees.sort_custom(func(a, b): return a["score"] > b["score"])
	if entrees.size() > 10: entrees = entrees.slice(0, 10)
	config.set_value("Leaderboard", "Entrees", entrees)
	config.save(LEADERBOARD_PATH)

func load_leaderboard() -> Array:
	var config = ConfigFile.new()
	var err = config.load(LEADERBOARD_PATH)
	if err != OK: return []
	return config.get_value("Leaderboard", "Entrees", [])

func afficher_leaderboard(entrees: Array) -> void:
	for i in range(entrees.size()):
		var e = entrees[i]
		game_ending.leaderboard_label.text += "%d. %s — %d pts\n"%[i+1, e["nom"], e["score"]]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("StopTime") and (Global.launched_mode > 0):
		pause_blocs = not pause_blocs
		cube_spawner.start_spawn = not pause_blocs
		for bloc in cube_spawner.blocs:
			if is_instance_valid(bloc):
				bloc.set_physics_process(not pause_blocs)
