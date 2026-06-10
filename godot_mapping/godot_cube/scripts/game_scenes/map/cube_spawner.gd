extends Node3D

@export var classic_bloc: PackedScene
@export var bonus_bloc: PackedScene
@export var bomb_bloc: PackedScene
@export var disappear_bloc: PackedScene
@export var splash_bloc: PackedScene
@export var shield_bloc: PackedScene
@export var heal_bloc: PackedScene
@onready var level_music: AudioStreamPlayer

@onready var start_label: Label = $"../StartLabel"
@onready var disappear_bloc_notif: Label = $"../DisappearBlocNotif"
@onready var shields: Array[GPUParticles3D] = [$"../Map/Boucliers/ShieldJ1", $"../Map/Boucliers/ShieldJ2"]

# Booléen de départ pour lancer l'apparition des cubes après le message de départ
var start_spawn: bool = false
# Booléen permettant de pré-générer les cubes, une seule fois, dans toute la partie
var is_generated: bool = false
# Générateur aléatoire de nombres pour tous les tirages aléatoires
var rng = RandomNumberGenerator.new()

# Liste de tous les types de cubes
var cube_list: Array[PackedScene]

# Texture sur lesquelles sont projetées les vues
var texture: TextureRect

# Temps de jeu écoulé
var elapsed_time: float = 0.0

# Temps pendant lesquels chacun des joueurs aura son bonus de multiplicateur (x2)
var bonus_time: Array[float] = [0.0, 0.0]
var count_bonus_time: Array[bool] = [false, false]

# Grille de jeu où vont apparaître les cubes
var grille = [[0.0, 0.5], [-2.0, 0.5], [2.0, 0.5], [0.0, 1.75], [-2.0, 1.75], [2.0, 1.75], [0.0, 3.0], [-2.0, 3.0], [2.0, 3.0]]
# Stockage des différents blocs du terrain
var blocs: Array[Node3D]

# Variables liées aux combos
var increment_seuil: Array[int] = [2,2]
var stocked_combo: Array[int] = [0, 0]
var best_combo: int = 0
var combo_success: bool = false

# Variables liées au combo visuel
var texture_progress_bars: Array[TextureProgressBar] = []
var progress_bar_labels: Array[Label] = []
var letters: Array[String] = ["D", "C", "B", "A", "S"]
var paliers: Array[int] = [2, 5, 10, 20, 30]
var passage_paliers: Array[bool] = [false, false]

# Multiplicateurs de score et scores actuels pour chaque joueur
var multiplicateur: Array[int] = [1, 1]

# Scores visuels des joueurs
var score_uis : Array = []
var j1: Node3D
var j2: Node3D

# Tableau associé à l'encre
var ink_overlay: Array[Node2D] = []

# Tableaux associés aux boucliers
var shield_actif: Array[int] = [0, 0]
var time_shield_actif: Array[float] = [0.0, 0.0]
var shield_bars: Array[Control] = []

# Variables associées à la vie limitée
var healing: bool = false
var health_bars: Array[Control] = []
var health: Array[int] = [10, 10]

# Variables de pixelisation
var pixelisation_active_j1: bool = false
var pixelisation_active_j2: bool = false
var pixelisation_time_j1: float = 0.0
var pixelisation_time_j2: float = 0.0

# Fonction appelée par le script du jeu pour démarrer l'apparition des cubes et charger les scores visuels
func activation() -> void:
	cube_list = [classic_bloc, bonus_bloc, bomb_bloc, disappear_bloc, splash_bloc, shield_bloc]
	if Global.healing: cube_list.append(heal_bloc)
	if Global.launched_mode == 0:
		j1 = get_node("../../SplitScreens/Camera1/POV1/J1")
		j2 = get_node("../../SplitScreens/Camera2/POV2/J2")

		# Ajout des scores et des barres de boucliers aux tableaux
		score_uis.append(get_node("../../SplitScreens/Camera1/POV1/ScoreUI"))
		score_uis.append(get_node("../../SplitScreens/Camera2/POV2/ScoreUI"))
		shield_bars.append(get_node("../../SplitScreens/Camera1/POV1/ShieldBar"))
		shield_bars.append(get_node("../../SplitScreens/Camera2/POV2/ShieldBar"))

		# Ajout des noeuds associés à l'encre
		ink_overlay.append(get_node("../../SplitScreens/Camera1/POV1/InkLayerJ1/InkOverlayJ1"))
		ink_overlay.append(get_node("../../SplitScreens/Camera2/POV2/InkLayerJ2/InkOverlayJ2"))
	else:
		j1 = get_node("../../J1")
		j2 = get_node("../../J2")
		level_music = get_node("../../LevelMusic")
		healing = Global.healing
		texture = get_node("../../TextureRect")
		
		if Global.launched_mode == 2:
			score_uis.append(get_node("../../J1/CameraController/Vue1/ScoreUI"))
			score_uis.append(get_node("../../J2/CameraController/Vue5/ScoreUI"))
			score_uis.append(get_node("../../J1/CameraController/Vue2/ScoreUI"))
			score_uis.append(get_node("../../J2/CameraController/Vue6/ScoreUI"))

			health_bars.append(get_node("../../J1/CameraController/Vue1/HealthBar"))
			health_bars.append(get_node("../../J2/CameraController/Vue5/HealthBar"))
			health_bars.append(get_node("../../J1/CameraController/Vue2/HealthBar"))
			health_bars.append(get_node("../../J2/CameraController/Vue6/HealthBar"))
			start_label.text = "Ready ?"

		shield_bars.append(get_node("../../J1/CameraController/Vue1/ShieldBar"))
		shield_bars.append(get_node("../../J2/CameraController/Vue5/ShieldBar"))
		shield_bars.append(get_node("../../J1/CameraController/Vue2/ShieldBar"))
		shield_bars.append(get_node("../../J2/CameraController/Vue6/ShieldBar"))

		ink_overlay.append(get_node("../../J1/CameraController/Vue1/InkLayerJ1/InkOverlayJ1"))
		ink_overlay.append(get_node("../../J2/CameraController/Vue5/InkLayerJ2/InkOverlayJ2"))
		ink_overlay.append(get_node("../../J1/CameraController/Vue2/InkLayerJ1/InkOverlayJ1"))
		ink_overlay.append(get_node("../../J2/CameraController/Vue6/InkLayerJ2/InkOverlayJ2"))

		texture_progress_bars.append(get_node("../../J1/CameraController/Vue1/ComboBar/MarginContainer/VBoxContainer/TextureProgressBar"))
		texture_progress_bars.append(get_node("../../J2/CameraController/Vue5/ComboBar/MarginContainer/VBoxContainer/TextureProgressBar"))
		texture_progress_bars.append(get_node("../../J1/CameraController/Vue2/ComboBar/MarginContainer/VBoxContainer/TextureProgressBar"))
		texture_progress_bars.append(get_node("../../J2/CameraController/Vue6/ComboBar/MarginContainer/VBoxContainer/TextureProgressBar"))

		progress_bar_labels.append(get_node("../../J1/CameraController/Vue1/ComboBar/MarginContainer/VBoxContainer/TextureProgressBar/ProgressBarLabel"))
		progress_bar_labels.append(get_node("../../J2/CameraController/Vue5/ComboBar/MarginContainer/VBoxContainer/TextureProgressBar/ProgressBarLabel"))
		progress_bar_labels.append(get_node("../../J1/CameraController/Vue2/ComboBar/MarginContainer/VBoxContainer/TextureProgressBar/ProgressBarLabel"))
		progress_bar_labels.append(get_node("../../J2/CameraController/Vue6/ComboBar/MarginContainer/VBoxContainer/TextureProgressBar/ProgressBarLabel"))
		
	for progress_bar in texture_progress_bars:
		progress_bar.max_value = paliers[0]
	for shield_bar in shield_bars:
		shield_bar.modulate.a = 0.0
	for health_bar in health_bars:
		if healing and Global.launched_mode == 2:
			health_bar.visible = true
			health_bar.modulate.a = 1.0
		else:
			health_bar.visible = false
			health_bar.modulate.a = 0.0
	start_game()

func start_game() -> void:
	if Global.launched_mode == 2:
		start_label.visible = true
		await get_tree().create_timer(0.5).timeout
		start_label.text = "GO !"
		var transition = create_tween()
		transition.tween_property(start_label, "modulate:a", 0.0, 0.5)
		await transition.finished
		start_label.visible = false
	start_spawn = true

func _process(delta: float) -> void:
	if start_spawn:
		elapsed_time += delta
		
		if pixelisation_active_j1: pixelisation_time_j1 += delta
		if pixelisation_active_j2: pixelisation_time_j2 += delta

		# On retire les blocs qui ont été supprimés du jeu
		blocs = blocs.filter(func(bloc): return is_instance_valid(bloc))

		for i in range(2):
			# On vérifie si les boucliers de chaque joueur doivent écourtés
			if shield_actif[i] == 0 and shields[i].emitting :
				shields[i].emitting = false
				shields[i].speed_scale = 10.0

				# Si le bouclier tombe à 0, on efface la barre associée
				var t = create_tween().set_parallel(true)
				t.tween_property(shield_bars[i], "modulate:a", 0.0, 0.01)
				if Global.launched_mode > 0: t.tween_property(shield_bars[i+2], "modulate:a", 0.0, 0.01)
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
				if Global.launched_mode > 0: t.tween_property(shield_bars[i+2], "modulate:a", 0.0, 0.01)
				await t.finished

			# On calcule le temps de bonus pour chacun des 2 joueurs et on arrête le bonus une fois que ce temps est dépassé
			if count_bonus_time[i]: bonus_time[i] += delta
			if bonus_time[i] >= 10.0 and multiplicateur[i] > 1:
				bonus_time[i] = 0.0
				multiplicateur[i] /= 2

		# On actualise le meilleur combo de cubes
		if best_combo < stocked_combo.max():
			best_combo = stocked_combo.max()
		
		match Global.launched_mode:
			# Boucle de jeu du jeu dans le menu
			0: menu_loop()
			# Boucle de jeu dans le tutoriel
			1: tutoriel_loop()
			# Boucle de jeu dans la partie
			2: game_loop()

func menu_loop() -> void:
	if blocs == []:
		var n: int
		if healing: n = rng.randi_range(0, 6)
		else: n = rng.randi_range(0, 5)
		# Si on est en phase de tutoriel, on peut avoir une liste de taille plus petite, donc, on change l'indice
		if not Global.setup_tutoriel:
			match Global.tutoriel_played_mode:
				0: n = 0
				1: n = 0
				2: n = rng.randi_range(0, 1)
				3: pass
		spawn_cube(cube_list[n])

# On actualise la barre de combo visuelle et on vérifie si un palier a été dépassé
func check_progress_bars() -> void:
	for i in range(2):
		texture_progress_bars[i].value = snapped(stocked_combo[i], texture_progress_bars[i].step)
		texture_progress_bars[i+2].value = snapped(stocked_combo[i], texture_progress_bars[i].step)

	# Si un palier a été dépassé, on passe au suivant et on incrémente le multiplicateur
	for i in range(2):
		if texture_progress_bars[i].value >= texture_progress_bars[i].max_value:
			texture_progress_bars[i].value = 0
			texture_progress_bars[i+2].value = 0
			multiplicateur[i] *= 2

			var current_index = letters.find(progress_bar_labels[i].text)
			var letter_index = clamp(current_index + 1, 0, paliers.size() - 1)
			progress_bar_labels[i].text = letters[letter_index]
			progress_bar_labels[i+2].text = letters[letter_index]
			
			if letter_index < paliers.size():
				passage_paliers[i] = true
				texture_progress_bars[i].max_value = paliers[letter_index]
				texture_progress_bars[i+2].max_value = paliers[letter_index]
	
	# A chaque palier passé par l'un des deux joueurs, l'autre subit un effet de pixelisation
	match passage_paliers:
		[false, false]: pass
		[false, true]:
			texture.material.set_shader_parameter("pixelisation_mask", [false, false, false, false, true, true, false, false])
			if not pixelisation_active_j2:
				pixelisation_active_j2 = true
				var pixelisationPower = texture.material.get_shader_parameter("pixelisationPower")
				texture.material.set_shader_parameter("pixelisation", true)
				texture.material.set_shader_parameter("pixelisationPower", pixelisationPower - 10.0)
		[true, false]:
			texture.material.set_shader_parameter("pixelisation_mask", [true, true, false, false, false, false, false, false])
			if not pixelisation_active_j1:
				pixelisation_active_j1 = true
				var pixelisationPower = texture.material.get_shader_parameter("pixelisationPower")
				texture.material.set_shader_parameter("pixelisation", true)
				texture.material.set_shader_parameter("pixelisationPower", pixelisationPower - 10.0)
		[true, true]:
			texture.material.set_shader_parameter("pixelisation_mask", [true, true, false, false, true, true, false, false])
			if (not pixelisation_active_j1) or (not pixelisation_active_j2):
				pixelisation_active_j1 = true
				pixelisation_active_j2 = true
				var pixelisationPower = texture.material.get_shader_parameter("pixelisationPower")
				texture.material.set_shader_parameter("pixelisation", true)
				texture.material.set_shader_parameter("pixelisationPower", pixelisationPower - 10.0)
	if pixelisation_time_j1 > 5.0:
		passage_paliers[0] = false
		pixelisation_active_j1 = false
	if pixelisation_time_j2 > 5.0:
		passage_paliers[1] = false
		pixelisation_active_j2 = false

func tutoriel_loop() -> void:
	check_progress_bars()
	match Global.tutoriel_played_mode:
		0:
			if Global.setup_tutoriel:
				Global.setup_tutoriel = false
				cube_list = [classic_bloc]
			menu_loop()
		1:
			if Global.setup_tutoriel:
				Global.setup_tutoriel = false
				cube_list = [bonus_bloc]
			menu_loop()
		2:
			if Global.setup_tutoriel:
				Global.setup_tutoriel = false
				cube_list = [classic_bloc, bonus_bloc]
			menu_loop()
		3:
			if Global.setup_tutoriel:
				Global.setup_tutoriel = false
				cube_list = [classic_bloc, bonus_bloc, bomb_bloc, disappear_bloc, splash_bloc, shield_bloc]
			menu_loop()

func game_loop() -> void:
	# On lance la musique avec un retard de 3 secondes pour permettre aux premiers cubes d'arriver
	if elapsed_time > 1.25 and (not level_music.playing): level_music.play()
	check_progress_bars()
	
	if not is_generated:
		is_generated = true

		# Pré-génération du niveau de la partie
		scheduled_bloc(classic_bloc, 4.75, 0, [0.0, 2.0], 4.0, 1)
		scheduled_bloc(classic_bloc, 5.0, 0, [0.0, 2.0], 4.0, 3)
		scheduled_bloc(classic_bloc, 4.75, 1, [-2.0, 2.0], 4.0, 1)
		scheduled_bloc(classic_bloc, 4.75, 1, [2.0, 2.0], 4.0, 1)

		scheduled_bloc(classic_bloc, 7.25, 0, [-2.0, 0.5], 4.0, 1)
		scheduled_bloc(classic_bloc, 7.25, 1, [-2.0, 2.0], 4.0, 2)

		scheduled_bloc(bonus_bloc, 10.0, 0, [0.0, 3.5], 8.0)
		scheduled_bloc(bonus_bloc, 10.0, 1, [-2.0, 0.5], 8.0)

		scheduled_bloc(bomb_bloc, 12.5, 0, [-2.0, 0.5], 6.0)
		scheduled_bloc(bomb_bloc, 12.5, 1, [2.0, 0.5], 6.0)
		scheduled_bloc(bomb_bloc, 12.5, 0, [2.0, 3.5], 6.0)
		scheduled_bloc(bomb_bloc, 12.5, 1, [-2.0, 3.5], 6.0)
		
		scheduled_bloc(classic_bloc, 14.75, 0, [-2.0, 2.0], 4.0, 1)
		scheduled_bloc(classic_bloc, 14.75, 0, [2.0, 2.0], 4.0, 1)
		scheduled_bloc(classic_bloc, 14.75, 1, [-2.0, 0.5], 4.0, 1)
		scheduled_bloc(classic_bloc, 14.75, 1, [2.0, 0.5], 4.0, 3)

func scheduled_bloc(scene_bloc: PackedScene, arrival_time: float, direction: int = rng.randi_range(0, 1),
spawn: Array[float] = [0.0, -1.0], absolute_speed: float = -1.0, color: int = rng.randi_range(1, 3)) -> void:
	if absolute_speed < 0: absolute_speed = rng.randf_range(5.0, 10.0)
	var travel_time = 15.0 / absolute_speed
	# Délai avant d'apparaître
	var delay_spawn_time = arrival_time - elapsed_time - travel_time
	if delay_spawn_time < 0: return
	else:
		spawn_cube_after_delay(scene_bloc, absolute_speed, direction, color, spawn, delay_spawn_time)

func spawn_cube_after_delay(scene_bloc: PackedScene, absolute_speed: float, direction: int,
color: int, spawn: Array[float], delay_spawn_time: float) -> void:
	await get_tree().create_timer(delay_spawn_time).timeout
	spawn_cube(scene_bloc, absolute_speed, direction, color, spawn)

func spawn_cube(scene_bloc: PackedScene, absolute_speed: float = -1.0, direction: int = rng.randi_range(0, 1),
color: int = rng.randi_range(1, 3), spawn: Array[float] = [0.0, -1.0]) -> void:
	var new_bloc = generate_bloc(scene_bloc)
	match scene_bloc:
		classic_bloc: setup_classic_bloc(new_bloc, color, absolute_speed, direction, spawn)
		bonus_bloc: setup_bonus_bloc(new_bloc, absolute_speed, direction, spawn)
		bomb_bloc: setup_bomb_bloc(new_bloc, absolute_speed, direction, spawn)
		disappear_bloc: setup_disappear_bloc(new_bloc, absolute_speed, direction, spawn)
		splash_bloc: setup_splash_bloc(new_bloc, absolute_speed, direction, spawn)
		shield_bloc: setup_shield_bloc(new_bloc, absolute_speed, direction, spawn)

func set_speed(bloc: Node3D, direction: int, absolute_speed: float, disappear: bool) -> void:
	match disappear:
		false: match direction:
				0:
					if absolute_speed < 0 : bloc.vitesse_deplacement = rng.randf_range(5.0, 10.0)
					else: bloc.vitesse_deplacement = absolute_speed
				1:
					if absolute_speed < 0 : bloc.vitesse_deplacement = rng.randf_range(-5.0, -10.0)
					else: bloc.vitesse_deplacement = -absolute_speed
		true: match direction:
				0:
					if absolute_speed < 0 : bloc.vitesse_deplacement = rng.randf_range(2.0, 4.0)
					else: bloc.vitesse_deplacement = absolute_speed
				1:
					if absolute_speed < 0 : bloc.vitesse_deplacement = rng.randf_range(-2.0, -4.0)
					else: bloc.vitesse_deplacement = -absolute_speed

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

func spawn_valide(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float], disappear: bool = false) -> void:
	if spawn[1] > 0: bloc.position = Vector3(spawn[0], spawn[1], 0.0)
	else:
		# On filtre les coordonnées restantes pour ne pas avoir des cubes qui se superposent
		var coord_restantes = grille.filter(case_valide)
		if coord_restantes == []: return

		var coord = coord_restantes[randi() % coord_restantes.size()]
		bloc.position = Vector3(coord[0], coord[1], 0.0)

	bloc.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	set_speed(bloc, direction, absolute_speed, disappear)

func setup_classic_bloc(bloc: Node3D, color: int, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On initialise de façon aléatoire la couleur du bloc
	bloc.color = color
	bloc.setup_color = true

	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(_onStrikedClassicCube_j1)
	bloc.missed_cube_j1.connect(_onMissedClassicCube_j1)
	bloc.striked_cube_j2.connect(_onStrikedClassicCube_j2)
	bloc.missed_cube_j2.connect(_onMissedClassicCube_j2)
	spawn_valide(bloc, absolute_speed, direction, spawn)

func setup_bonus_bloc(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(_onStrikedBonusCube_j1)
	bloc.striked_cube_j2.connect(_onStrikedBonusCube_j2)
	spawn_valide(bloc, absolute_speed, direction, spawn)

func setup_bomb_bloc(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(_onStrikedBombCube_j1)
	bloc.striked_cube_j2.connect(_onStrikedBombCube_j2)
	spawn_valide(bloc, absolute_speed, direction, spawn)

func setup_disappear_bloc(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(_onStrikedDisappearCube_j1)
	bloc.striked_cube_j2.connect(_onStrikedDisappearCube_j2)
	spawn_valide(bloc, absolute_speed, direction, spawn, true)

func setup_splash_bloc(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(_onStrikedSplashCube_j1)
	bloc.striked_cube_j2.connect(_onStrikedSplashCube_j2)
	spawn_valide(bloc, absolute_speed, direction, spawn)

func setup_shield_bloc(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(_onStrikedShieldCube_j1)
	bloc.striked_cube_j2.connect(_onStrikedShieldCube_j2)
	spawn_valide(bloc, absolute_speed, direction, spawn)

func setup_heal_bloc(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(_onStrikedHealCube_j1)
	bloc.striked_cube_j2.connect(_onStrikedHealCube_j2)
	spawn_valide(bloc, absolute_speed, direction, spawn)

func StrikedClassicCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 1000
	if Global.launched_mode == 2:
		score_uis[i].ajouter_score(gain)
		score_uis[i+2].ajouter_score(gain)

func MissedClassicCube(i: int) -> void:
	if shield_actif[i] > 0:
		shield_actif[i] -= 1
		var current = shields[i].material_override.get_shader_parameter("MaskPower")
		shields[i].material_override.set_shader_parameter("MaskPower", current + 2.0)
		shield_bars[i].update_shield(shield_actif[i])
		if Global.launched_mode > 0: shield_bars[i+2].update_shield(shield_actif[i])
	else:
		multiplicateur[i] = 1
		stocked_combo[i] = 0
		if Global.launched_mode > 0:
			texture_progress_bars[i].value = 0
			texture_progress_bars[i+2].value = 0
			progress_bar_labels[i].text = letters[0]
			progress_bar_labels[i+2].text = letters[0]
		if healing and Global.launched_mode == 2:
			health[i] -= 1
			health_bars[i].update_health(health[i])
			health_bars[i+2].update_health(health[i])

func StrikedBonusCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 5000
	multiplicateur[i] *= 2
	count_bonus_time[i] = true
	if Global.launched_mode == 2:
		score_uis[i].ajouter_score(gain)
		score_uis[i+2].ajouter_score(gain)

func StrikedBombCube(i: int) -> void:
	stocked_combo[i] = 0
	var gain = -500
	multiplicateur[i] = 1
	if Global.launched_mode == 2:
		score_uis[i].ajouter_score(gain)
		score_uis[i+2].ajouter_score(gain)

func StrikedDisappearCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 15000
	multiplicateur[i] *= 2
	if Global.launched_mode == 2:
		score_uis[i].ajouter_score(gain)
		score_uis[i+2].ajouter_score(gain)
	# On montre une notification au joueur pour lui dire qu'il a frappé le cube
	disappear_bloc_notif.visible = true
	await get_tree().create_timer(1.0).timeout
	disappear_bloc_notif.visible = false

func StrikedSplashCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 1000
	if Global.launched_mode == 2:
		score_uis[i].ajouter_score(gain)
		score_uis[i+2].ajouter_score(gain)
	# On déclenche le visuel d'encre
	ink_overlay[i].trigger_ink()

func StrikedShieldCube(i: int) -> void:
	# On initialise la barre de vie, la durée et le visuel du bouclier
	shields[i].emitting = true
	shields[i].speed_scale = 1.0
	shields[i].material_override.set_shader_parameter("MaskPower", -5.0)
	shield_actif[i] = 5
	time_shield_actif[i] = 10.0

	shield_bars[i].visible = true
	if Global.launched_mode: shield_bars[i+2].visible = true

	var t = create_tween().set_parallel(true)
	t.tween_property(shield_bars[i], "modulate:a", 1.0, 0.1)
	if Global.launched_mode: t.tween_property(shield_bars[i+2], "modulate:a", 1.0, 0.1)
	await t.finished

	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 1000
	if Global.launched_mode == 2:
		score_uis[i].ajouter_score(gain)
		score_uis[i+2].ajouter_score(gain)

func StrikedHealCube(i: int) -> void:
	health[i] += 1
	health_bars[i].update_health(health[i])
	health_bars[i+2].update_health(health[i])

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

func _onStrikedHealCube_j1() -> void:
	StrikedHealCube(0)

func _onStrikedHealCube_j2() -> void:
	StrikedHealCube(1)
