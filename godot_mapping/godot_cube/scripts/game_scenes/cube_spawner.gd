extends Node3D

@export var classic_bloc: PackedScene
@export var bonus_bloc: PackedScene
@export var bomb_bloc: PackedScene
@export var disappear_bloc: PackedScene
@export var splash_bloc: PackedScene
@export var shield_bloc: PackedScene
@onready var start_label: Label = $"../StartLabel"
@onready var disappear_bloc_notif: Label = $"../DisappearBlocNotif"
@onready var shields: Array[GPUParticles3D] = [$"../Map/Boucliers/ShieldJ1", $"../Map/Boucliers/ShieldJ2"]

# Booléen de départ décidant du mode de jeu lancé : false pour le menu, true pour la TV
var mode: bool = false
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
var grille = [[0.0, 0.5], [-2.0, 0.5], [2.0, 0.5], [0.0, 1.75], [-2.0, 1.75], [2.0, 1.75], [0.0, 3.0], [-2.0, 3.0], [2.0, 3.0]]
# Stockage des différents blocs du terrain
var blocs: Array[Node3D]

# Variables liées aux combos
var seuil: Array[int] = [2,2]
var stocked_combo: Array[int] = [0, 0]
var best_combo: int = 0
var combo_success: bool = false

# Multiplicateurs de score et scores actuels pour chaque joueur
var multiplicateur: Array[int] = [1, 1]

# Scores visuels des joueurs
var score_uis : Array = []
var j1: Node3D
var j2: Node3D

# Tableau associé à l'encre
var ink_overlay: Array[Node2D]

# Tableaux associés aux boucliers
var shield_actif: Array[int] = [0, 0]
var time_shield_actif: Array[float] = [0.0, 0.0]
var shield_bars: Array[Control]

# Fonction appelée par le script du jeu pour démarrer l'apparition des cubes et charger les scores visuels
func activation() -> void:
	j1 = get_node_or_null("../../SplitScreens/Camera1/POV1/J1")
	j2 = get_node_or_null("../../SplitScreens/Camera2/POV2/J2")

	# Ajout des scores et des barres de boucliers aux tableaux
	score_uis.append(get_node_or_null("../../SplitScreens/Camera1/POV1/ScoreUI"))
	score_uis.append(get_node_or_null("../../SplitScreens/Camera2/POV2/ScoreUI"))
	shield_bars.append(get_node_or_null("../../SplitScreens/Camera1/POV1/ShieldBar"))
	shield_bars.append(get_node_or_null("../../SplitScreens/Camera2/POV2/ShieldBar"))
	
	# Ajout des noeuds associés à l'encre
	ink_overlay.append(get_node_or_null("../../SplitScreens/Camera1/POV1/InkLayerJ1/InkOverlayJ1"))
	ink_overlay.append(get_node_or_null("../../SplitScreens/Camera2/POV2/InkLayerJ2/InkOverlayJ2"))
	if not j1 and not j2:
		score_uis = []
		shield_bars = []
		mode = true
		j1 = get_node_or_null("../../J1")
		j2 = get_node_or_null("../../J2")
		score_uis.append(get_node_or_null("../../J1/CameraControllerFPS/Vue1/ScoreUI"))
		score_uis.append(get_node_or_null("../../J2/CameraControllerFPS/Vue5/ScoreUI"))
		score_uis.append(get_node_or_null("../../J1/CameraControllerFPS/Vue2/ScoreUI"))
		score_uis.append(get_node_or_null("../../J2/CameraControllerFPS/Vue6/ScoreUI"))
		shield_bars.append(get_node_or_null("../../J1/CameraControllerFPS/Vue1/ShieldBar"))
		shield_bars.append(get_node_or_null("../../J2/CameraControllerFPS/Vue5/ShieldBar"))
		shield_bars.append(get_node_or_null("../../J1/CameraControllerFPS/Vue2/ShieldBar"))
		shield_bars.append(get_node_or_null("../../J2/CameraControllerFPS/Vue6/ShieldBar"))
		ink_overlay.append(get_node_or_null("../../J1/CameraControllerFPS/Vue1/InkLayerJ1/InkOverlayJ1"))
		ink_overlay.append(get_node_or_null("../../J2/CameraControllerFPS/Vue5/InkLayerJ2/InkOverlayJ2"))
		ink_overlay.append(get_node_or_null("../../J1/CameraControllerFPS/Vue2/InkLayerJ1/InkOverlayJ1"))
		ink_overlay.append(get_node_or_null("../../J2/CameraControllerFPS/Vue6/InkLayerJ2/InkOverlayJ2"))
	for shield_bar in shield_bars:
		shield_bar.modulate.a = 0.0
	start_game()

func start_game() -> void:
	if mode:
		start_label.visible = true
		await get_tree().create_timer(0.5).timeout
		start_label.text = "GO !"
		var transition = create_tween()
		transition.tween_property(start_label, "modulate:a", 0.0, 0.5)
		await transition.finished
		start_label.visible = false
	start_spawn = true
	generate_shield_bloc()

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
		
		# On vérifie si les boucliers de chaque joueur doivent écourtés
		for i in range(2):
			if shield_actif[i] == 0 and shields[i].emitting :
				shields[i].emitting = false
				shields[i].speed_scale = 10.0

				# Si le bouclier tombe à 0, on efface la barre associée
				var t = create_tween().set_parallel(true)
				t.tween_property(shield_bars[i], "modulate:a", 0.0, 0.01)
				if mode: t.tween_property(shield_bars[i+2], "modulate:a", 0.0, 0.01)
				await t.finished

			elif shields[i].emitting:
				time_shield_actif[i] -= delta
			
		# Si le temps d'activité est dépassé, on réinitialise le nombre de cubes pouvant être ratés
			if time_shield_actif[i] <= 0.0:
				shield_actif[i] = 0
				shields[i].emitting = false
				shields[i].speed_scale = 10.0
				
				# On efface les barres des boucliers sur l'écran
				var t = create_tween().set_parallel(true)
				t.tween_property(shield_bars[i], "modulate:a", 0.0, 0.01)
				if mode: t.tween_property(shield_bars[i+2], "modulate:a", 0.0, 0.01)
				await t.finished
			
		# On retire les blocs qui ont été supprimés du jeu
		blocs = blocs.filter(func(bloc): return is_instance_valid(bloc))
		if blocs == []:
			generate_classic_bloc()

		# On actualise le meilleur combo de cubes
		if best_combo < stocked_combo.max():
			best_combo = stocked_combo.max()

		# Si un certain combo est atteint par l'un des 2 joueurs, on incrémente la vitesse
		if stocked_combo.min() >= seuil.min():
			for bloc in blocs : increment_speed(bloc)

		# Selon qui a incrémenté la vitesse, on incrémente son multiplicateur de score
		for i in range(2):
			if stocked_combo[i] >= seuil[i]:
				multiplicateur[i] *= 2
				combo_success = true
			if combo_success: seuil[i] += 2
		
		# On fait apparaître un bloc bonus à chaque fois que le temps de seuil est dépassé
		if elapsed_time >= threshold_time:
			elapsed_time -= threshold_time
			threshold_time = rng.randf_range(3.0, 10.0)
		
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
	# On fait une disjonction de cas pour que le cube donnant un bouclier soit seul sur sa colonne
	for bloc in blocs:
		if bloc != shield_bloc:
			if case == [bloc.position.x, bloc.position.y]: return false
		else:
			if case[0] == bloc.position.x: return false
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

func generate_splash_bloc() -> void:
	var new_bloc = generate_bloc(splash_bloc)
	
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	new_bloc.striked_cube_j1.connect(_onStrikedSplashCube_j1)
	new_bloc.striked_cube_j2.connect(_onStrikedSplashCube_j2)
	spawn_valide(new_bloc)

func generate_shield_bloc() -> void:
	var new_bloc = generate_bloc(shield_bloc)
	
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	new_bloc.striked_cube_j1.connect(_onStrikedShieldCube_j1)
	new_bloc.striked_cube_j2.connect(_onStrikedShieldCube_j2)
	spawn_valide(new_bloc)

func StrikedClassicCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 1000
	score_uis[i].ajouter_score(gain)
	if mode: score_uis[i+2].ajouter_score(gain)

func MissedClassicCube(i: int) -> void:
	if shield_actif[i] > 0:
		shield_actif[i] -= 1
		var current = shields[i].material_override.get_shader_parameter("MaskPower")
		shields[i].material_override.set_shader_parameter("MaskPower", current + 2.0)
		shield_bars[i].update_shield(shield_actif[i])
		if mode : shield_bars[i+2].update_shield(shield_actif[i])
	else:
		multiplicateur[i] = 1
		stocked_combo[i] = 0
		seuil[i] = 2

func StrikedBonusCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 5000
	multiplicateur[i] *= 2
	count_bonus_time[i] = true
	score_uis[i].ajouter_score(gain)
	if mode: score_uis[i+2].ajouter_score(gain)

func StrikedBombCube(i: int) -> void:
	stocked_combo[i] = 0
	var gain = -500
	multiplicateur[i] = 1
	score_uis[i].ajouter_score(gain)
	if mode: score_uis[i+2].ajouter_score(gain)

func StrikedDisappearCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 15000
	multiplicateur[i] *= 2
	score_uis[i].ajouter_score(gain)
	if mode: score_uis[i+2].ajouter_score(gain)
	disappear_bloc_notif.visible = true
	await get_tree().create_timer(1.0).timeout
	disappear_bloc_notif.visible = false

func StrikedSplashCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 1000
	score_uis[i].ajouter_score(gain)
	if mode: score_uis[i+2].ajouter_score(gain)
	ink_overlay[i].trigger_ink()

func StrikedShieldCube(i: int) -> void:
	# On initialise la barre de vie, la durée et le visuel du bouclier
	shields[i].emitting = true
	shields[i].speed_scale = 1.0
	shields[i].material_override.set_shader_parameter("MaskPower", -5.0)
	shield_actif[i] = 5
	time_shield_actif[i] = 10.0
	
	shield_bars[i].visible = true
	if mode: shield_bars[i+2].visible = true
	
	var t = create_tween().set_parallel(true)
	t.tween_property(shield_bars[i], "modulate:a", 1.0, 0.1)
	if mode: t.tween_property(shield_bars[i+2], "modulate:a", 1.0, 0.1)
	await t.finished

	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 1000
	score_uis[i].ajouter_score(gain)
	if mode: score_uis[i+2].ajouter_score(gain)

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

func _onStrikedSplashCube_j1() -> void:
	StrikedSplashCube(0)

func _onStrikedSplashCube_j2() -> void:
	StrikedSplashCube(1)

func _onStrikedShieldCube_j1() -> void:
	StrikedShieldCube(0)

func _onStrikedShieldCube_j2() -> void:
	StrikedShieldCube(1)
