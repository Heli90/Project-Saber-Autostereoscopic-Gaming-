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
# Vitesse initiale de tous les cubes
var default_speed: float = 8.0

# Texture sur lesquelles sont projetées les vues
var texture: TextureRect

# Temps de jeu écoulé et booléens liées aux phases des niveaux
var elapsed_time: float = 0.0
var first_imp_phase: bool = false
var snd_imp_phase: bool = false
var end_phase: bool = false

# Temps pendant lesquels chacun des joueurs aura son bonus de multiplicateur (x2)
var bonus_time: Array[float] = [0.0, 0.0]
var count_bonus_time: Array[bool] = [false, false]

# Grille de jeu où vont apparaître les cubes
var grille = [[0.0, 0.5], [-2.0, 0.5], [2.0, 0.5], [0.0, 1.75], [-2.0, 1.75], [2.0, 1.75], [0.0, 3.0], [-2.0, 3.0], [2.0, 3.0]]
# Stockage des différents blocs du terrain
var blocs: Array[Node3D]

# Booléens pour générer le cube dans la zone d'effets, une seule fois, et pour appliquer l'effet, une seule fois
var is_effect_cube_generated: bool = false
var is_effect_applied: bool = false
# Temps depuis le dernier effet appliqué
var last_effect_applied_time: float = 0.0
# Nombre de rebonds effectués par ce cube
var rebonds: int = 0

# Booléen de départ pour décider quand il faut commencer la boucle d'effets dans la zone d'effets
var start_loop_in_effect_map: bool = false
# Booléen de départ pour décider quand il faut arrêter la boucle d'effets dans la zone d'effets
var stop_loop_in_effect_map: bool = false

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
# Variables de nausée
var nausea_tween: Tween
var hitted_bomb: Array[bool] = [false, false]
var nausea_time_j1: float = 0.0
var nausea_time_j2: float = 0.0

# Message d'avertissement sur l'effet qui va être déclenché dans la zone d'effets
var warning: Label

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
		level_music = get_node("../../LevelMusic")
		texture = get_node("../../TextureRect")
		if Global.launched_mode == 3: warning = get_node("../../Warning")
		# Dans les autres zones, il n'y a pas de joueurs
		if Global.launched_mode < 3:
			j1 = get_node("../../J1")
			j2 = get_node("../../J2")
			healing = Global.healing
			
			if Global.launched_mode == 2:
				score_uis.append(get_node("../../J1/CameraController/Vue1/ScoreUI"))
				score_uis.append(get_node("../../J2/CameraController/Vue5/ScoreUI"))
				score_uis.append(get_node("../../J1/CameraController/Vue2/ScoreUI"))
				score_uis.append(get_node("../../J2/CameraController/Vue6/ScoreUI"))

				health_bars.append(get_node("../../J1/CameraController/Vue1/HealthBar"))
				health_bars.append(get_node("../../J2/CameraController/Vue5/HealthBar"))
				health_bars.append(get_node("../../J1/CameraController/Vue2/HealthBar"))
				health_bars.append(get_node("../../J2/CameraController/Vue6/HealthBar"))

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
	# On retire les blocs qui ont été supprimés du jeu
	blocs = blocs.filter(func(bloc): return is_instance_valid(bloc))

	# Une boucle à part est dédiée à la zone de test des effets
	if Global.launched_mode == 3:
		if start_loop_in_effect_map: effect_loop(delta)
		else: pass
	# Le jeu est mis en pause lorsqu'on modifie l'espace interoculaire
	elif Global.launched_mode == 4:
		get_tree().paused = true
	else:
		if start_spawn:
			elapsed_time += delta
			
			if pixelisation_active_j1: pixelisation_time_j1 += delta
			if pixelisation_active_j2: pixelisation_time_j2 += delta

			for i in range(2):
				# On vérifie si les boucliers de chaque joueur doivent écourtés
				if shield_actif[i] == 0 and shields[i].emitting :
					shields[i].emitting = false
					shields[i].speed_scale = 10.0

					# Si le bouclier tombe à 0, on efface la barre associée
					var t = create_tween().set_parallel(true)
					t.tween_property(shield_bars[i], "modulate:a", 0.0, 0.01)
					if mode_with_sabers(): t.tween_property(shield_bars[i+2], "modulate:a", 0.0, 0.01)
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
					if mode_with_sabers(): t.tween_property(shield_bars[i+2], "modulate:a", 0.0, 0.01)
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
				2: game_loop(delta)

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

# Fonctions dédiées à l'application de tous les effets visuels
func invert_views() -> void:
	var invert = texture.material.get_shader_parameter("invertViews")
	texture.material.set_shader_parameter("invertViews", not invert)

func increase_pixelisation() -> void:
	var pixelisationPower = texture.material.get_shader_parameter("pixelisationPower")
	texture.material.set_shader_parameter("pixelisation", true)
	texture.material.set_shader_parameter("pixelisationPower", pixelisationPower - 10.0)

func reset_pixelisation() -> void:
	texture.material.set_shader_parameter("pixelisation", false)
	texture.material.set_shader_parameter("pixelisationPower", 200.0)

func increase_pixelisation_in_effect_map() -> void:
	texture.material.set_shader_parameter("pixelisation_mask", [true, true, false, false, true, true, false, false])
	increase_pixelisation()

func increase_glitch() -> void:
	var offset = texture.material.get_shader_parameter("offset")
	texture.material.set_shader_parameter("offset", offset+0.01)
	
func reset_glitch() -> void:
	texture.material.set_shader_parameter("offset", 0.0)

func red_screen() -> void:
	texture.material.set_shader_parameter("red_screen", true)
	var t: Tween = create_tween()
	t.tween_method(func(v: float): texture.material.set_shader_parameter("intensity_color", v), 0.0, 1.0, 0.5)
	await t.finished

func reset_red_screen() -> void:
	var t: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_method(func(v: float): texture.material.set_shader_parameter("intensity_color", v), 1.0, 0.0, 0.5)
	await t.finished
	texture.material.set_shader_parameter("red_screen", false)

func green_screen() -> void:
	texture.material.set_shader_parameter("green_screen", true)
	var t: Tween = create_tween()
	t.tween_method(func(v: float): texture.material.set_shader_parameter("intensity_color", v), 0.0, 1.0, 0.5)
	await t.finished

func reset_green_screen() -> void:
	var t: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_method(func(v: float): texture.material.set_shader_parameter("intensity_color", v), 1.0, 0.0, 0.5)
	await t.finished
	texture.material.set_shader_parameter("green_screen", false)

func blue_screen() -> void:
	texture.material.set_shader_parameter("blue_screen", true)
	var t: Tween = create_tween()
	t.tween_method(func(v: float): texture.material.set_shader_parameter("intensity_color", v), 0.0, 1.0, 0.5)
	await t.finished

func reset_blue_screen() -> void:
	var t: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_method(func(v: float): texture.material.set_shader_parameter("intensity_color", v), 1.0, 0.0, 0.5)
	await t.finished
	texture.material.set_shader_parameter("blue_screen", false)

func change_color_on_effect_map(i: int) -> void:
	match i:
		0: await red_screen()
		1: await green_screen()
		2: await blue_screen()

func rainbow_screen(start_value: float, end_value: float) -> void:
	texture.material.set_shader_parameter("rainbow_screen", true)
	var t: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_method(func(v: float): texture.material.set_shader_parameter("intensity_color", v), start_value, end_value, 0.25)
	await t.finished

func reset_rainbow_screen(current_value) -> void:
	var t: Tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_method(func(v: float): texture.material.set_shader_parameter("intensity_color", v), current_value, 0.0, 0.5)
	await t.finished
	texture.material.set_shader_parameter("rainbow_screen", false)

func nausea_screen(joueurs: Array[bool]) -> void:
	if nausea_tween and nausea_tween.is_running(): nausea_tween.kill()
	texture.material.set_shader_parameter("nausea_screen", true)
	match joueurs:
		[false, false]: texture.material.set_shader_parameter("nausea_mask", [false, false, false, false, false, false, false, false])
		[true, false]: texture.material.set_shader_parameter("nausea_mask", [true, true, false, false, false, false, false, false])
		[false, true]: texture.material.set_shader_parameter("nausea_mask", [false, false, false, false, true, true, false, false])
		[true, true]: texture.material.set_shader_parameter("nausea_mask", [true, true, false, false, true, true, false, false])
	nausea_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	nausea_tween.tween_method(func(v: float): texture.material.set_shader_parameter("nausea_strength", v), 0.0, 0.05, 0.05)
	await nausea_tween.finished

func reset_nausea_screen() -> void:
	if nausea_tween and nausea_tween.is_running(): nausea_tween.kill()
	nausea_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	nausea_tween.tween_method(func(v: float): texture.material.set_shader_parameter("nausea_strength", v), 0.05, 0.0, 0.5)
	await nausea_tween.finished
	await get_tree().create_timer(0.25).timeout
	texture.material.set_shader_parameter("nausea_mask", [false, false, false, false, false, false, false, false])
	texture.material.set_shader_parameter("nausea_screen", false)

func vignette_screen(start_value: float, end_value: float) -> void:
	texture.material.set_shader_parameter("vignette_screen", true)
	var t := create_tween()
	t.tween_method(func(v: float): texture.material.set_shader_parameter("vignette_strength", v), start_value, end_value, 0.5)
	await t.finished

func reset_vignette_screen(current_value) -> void:
	var t := create_tween()
	t.tween_method(func(v: float): texture.material.set_shader_parameter("vignette_strength", v), current_value, 0.0, 0.5)
	await t.finished
	texture.material.set_shader_parameter("vignette_screen", false)

func effect_loop(delta: float) -> void:
	# De 1 à 2, on teste l'effet d'inversion des vues
	# De 3 à 7, on teste l'effet de pixelisation
	# De 9 à 11, on teste l'effet de "glitch"
	# De 13 à 17, on teste l'effet de recoloration
	# De 19 à 20, on teste l'effet arc-en-ciel
	# De 22 à 23, on teste l'effet de nausée
	# De 24 à 25, on teste l'effet de vignette
	# A la fin de la boucle, on demande aux joueurs s'ils veulent répéter la séquence d'effets
	if not is_effect_cube_generated:
		is_effect_cube_generated = true
		spawn_cube(classic_bloc, 20.0, 0, 3, [0.0, 2.0])
	
	for bloc in blocs:
		if abs(bloc.position.z) > 15.0 and last_effect_applied_time <= 0.0:
			rebonds += 1
			is_effect_applied = false
			last_effect_applied_time = 1.0
			bloc.vitesse_deplacement = -bloc.vitesse_deplacement
	
	# On décremente le temps comptant le temps depuis lequel le dernier effet a été déclenché
	if last_effect_applied_time > 0.0: last_effect_applied_time -= delta
	
	# On affiche temporairement le texte pour annoncer le prochain effet
	if not warning.text.is_empty():
		warning.modulate.a = 1.0
		warning.visible = true

		var transition = create_tween()
		transition.tween_interval(0.5)
		transition.tween_property(warning, "modulate:a", 0.0, 0.3)
		await transition.finished
		warning.visible = false
		warning.text = ""
	
	if not is_effect_applied and last_effect_applied_time > 0.0:
		is_effect_applied = true
		match rebonds:
			1: invert_views()
			2:
				warning.text = "PIXELISATION"
				invert_views()
			3: increase_pixelisation_in_effect_map()
			4: increase_pixelisation_in_effect_map()
			5: increase_pixelisation_in_effect_map()
			6: increase_pixelisation_in_effect_map()
			7: increase_pixelisation_in_effect_map()
			8:
				warning.text = "GLITCH"
				reset_pixelisation()
			9: increase_glitch()
			10: increase_glitch()
			11: increase_glitch()
			12:
				warning.text = "RED"
				reset_glitch()
			13: change_color_on_effect_map(0)
			14:
				warning.text = "GREEN"
				reset_red_screen()
			15: change_color_on_effect_map(1)
			16:
				warning.text = "BLUE"
				reset_green_screen()
			17: change_color_on_effect_map(2)
			18:
				warning.text = "RAINBOW"
				reset_blue_screen()
			19: rainbow_screen(0.0, 0.5)
			20: rainbow_screen(0.5, 1.0)
			21:
				warning.text = "NAUSEA"
				reset_rainbow_screen(1.0)
			22: nausea_screen([true, true])
			23:
				warning.text = "VIGNETTE"
				reset_nausea_screen()
			24: vignette_screen(0.0, 1.0)
			25:
				await reset_vignette_screen(1.0)
				start_loop_in_effect_map = false
				stop_loop_in_effect_map = true

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
			stocked_combo[i] = 0
			multiplicateur[i] *= 2

			var current_index = letters.find(progress_bar_labels[i].text)
			var letter_index = clamp(current_index + 1, 0, paliers.size() - 1)
			progress_bar_labels[i].text = letters[letter_index]
			progress_bar_labels[i+2].text = letters[letter_index]
			
			if letter_index < paliers.size():
				passage_paliers[i] = true
				texture_progress_bars[i].max_value = paliers[letter_index]
				texture_progress_bars[i+2].max_value = paliers[letter_index]
	
	# On déclenche la pixelisation
	match passage_paliers:
		[false, false]: pass
		[true, false]:
			if not pixelisation_active_j1:
				pixelisation_active_j1 = true
				pixelisation_time_j1 = 0.0
				texture.material.set_shader_parameter("pixelisation_mask", [true, true, false, false, false, false, false, false])
				increase_pixelisation()
		[false, true]:
			if not pixelisation_active_j2:
				pixelisation_active_j2 = true
				pixelisation_time_j2 = 0.0
				texture.material.set_shader_parameter("pixelisation_mask", [false, false, false, false, true, true, false, false])
				increase_pixelisation()
		[true, true]:
			if (not pixelisation_active_j1) or (not pixelisation_active_j2):
				pixelisation_active_j1 = true
				pixelisation_time_j1 = 0.0
				pixelisation_active_j2 = true
				pixelisation_time_j2 = 0.0
				texture.material.set_shader_parameter("pixelisation_mask", [true, true, false, false, true, true, false, false])
				increase_pixelisation()

	# Gestion des fins de pixelisation
	if pixelisation_time_j1 > 5.0:
		pixelisation_time_j1 = 0.0
		pixelisation_active_j1 = false
		passage_paliers[0] = false
		if not pixelisation_active_j2:
			reset_pixelisation()
			texture.material.set_shader_parameter("pixelisation_mask", [false, false, false, false, false, false, false, false])
		else:
			texture.material.set_shader_parameter("pixelisation_mask", [false, false, false, false, true, true, false, false])

	if pixelisation_time_j2 > 5.0:
		pixelisation_time_j2 = 0.0
		pixelisation_active_j2 = false
		passage_paliers[1] = false
		if not pixelisation_active_j1:
			reset_pixelisation()
			texture.material.set_shader_parameter("pixelisation_mask", [false, false, false, false, false, false, false, false])
		else:
			texture.material.set_shader_parameter("pixelisation_mask", [true, true, false, false, false, false, false, false])

func tutoriel_loop() -> void:
	check_progress_bars()
	# On définit les cubes qui apparaissent selon le mode choisi
	if Global.setup_tutoriel: Global.setup_tutoriel = false
	menu_loop()

func on_bomb_hit(i: int):
	if i == 0: nausea_time_j1 = 5.0
	else: nausea_time_j2 = 5.0

func game_loop(delta: float) -> void:
	# On lance la musique avec un retard de 1.25 secondes pour permettre aux premiers cubes d'arriver
	if elapsed_time > 1.25 and (not level_music.playing): level_music.play()
	check_progress_bars()
	
	# Déclenchement des effets de vignette à des temps précis
	if elapsed_time > 25.0 and not first_imp_phase:
		first_imp_phase = true
		vignette_screen(0.0, 0.5)
	elif elapsed_time > 50.0 and not snd_imp_phase:
		snd_imp_phase = true
		vignette_screen(0.5, 1.0)
	elif elapsed_time > 70.0 and not end_phase:
		end_phase = true
		vignette_screen(1.0, 0.0)
	
	if nausea_time_j1 > 0: nausea_time_j1 -= delta
	else: nausea_time_j1 = 0
	if nausea_time_j2 > 0: nausea_time_j2 -= delta
	else: nausea_time_j2 = 0

	var j1_has_nausea = nausea_time_j1 > 0
	var j2_has_nausea = nausea_time_j2 > 0

	if (not j1_has_nausea) and not (j2_has_nausea):
		if hitted_bomb != [false, false]:
			hitted_bomb = [false, false]
			reset_nausea_screen()
	else: nausea_screen([j1_has_nausea, j2_has_nausea])

	if not is_generated:
		# Pré-génération du niveau de la partie
		is_generated = true
		
		# Phase 1
		scheduled_bloc(classic_bloc, 4.75, 0, [0.0, 1.75], default_speed, 2)
		scheduled_bloc(classic_bloc, 4.75, 1, [0.0, 1.75], default_speed, 2)
		scheduled_bloc(classic_bloc, 6.00, 0, [-2.0, 1.75], default_speed, 1)
		scheduled_bloc(classic_bloc, 6.00, 1, [2.0, 1.75], default_speed, 1)
		scheduled_bloc(classic_bloc, 7.25, 0, [0.0, 3.0], default_speed, 1)
		scheduled_bloc(classic_bloc, 7.25, 1, [0.0, 0.5], default_speed, 1)

		# Phase 2
		scheduled_bloc(bonus_bloc, 10.00, 0, [2.0, 1.75], default_speed)
		scheduled_bloc(bonus_bloc, 10.00, 1, [0.0, 1.75], default_speed)
		scheduled_bloc(bomb_bloc, 12.50, 0, [-2.0, 3.0], default_speed)
		scheduled_bloc(bomb_bloc, 12.50, 1, [2.0, 3.0], default_speed)
		scheduled_bloc(classic_bloc, 12.50, 0, [2.0, 0.5], default_speed, 2)
		scheduled_bloc(classic_bloc, 12.50, 1, [-2.0, 0.5], default_speed, 2)
		scheduled_bloc(classic_bloc, 14.75, 0, [0.0, 3.0], default_speed, 3)
		scheduled_bloc(classic_bloc, 14.75, 0, [2.0, 1.75], default_speed, 2)
		scheduled_bloc(classic_bloc, 14.75, 1, [-2.0, 1.75], default_speed, 3)
		scheduled_bloc(classic_bloc, 14.75, 1, [2.0, 0.5], default_speed, 2)
		scheduled_bloc(shield_bloc, 16.50, 0, [-2.0, 0.5], default_speed)
		scheduled_bloc(shield_bloc, 16.50, 1, [2.0, 3.0], default_speed)
		scheduled_bloc(classic_bloc, 24.75, 0, [0.0, 3.0], default_speed, 3)
		scheduled_bloc(classic_bloc, 24.75, 1, [0.0, 1.75], default_speed, 3)
		scheduled_bloc(classic_bloc, 24.75, 0, [-2.0, 3.0], default_speed, 2)
		scheduled_bloc(classic_bloc, 24.75, 1, [2.0, 3.0], default_speed, 2)

		# Phase 3
		default_speed *= 1.2
		scheduled_bloc(classic_bloc, 27.50, 0, [-2.0, 0.5], default_speed, 2)
		scheduled_bloc(classic_bloc, 27.50, 0, [2.0, 3.0], default_speed, 2)
		scheduled_bloc(classic_bloc, 27.50, 1, [2.0, 0.5], default_speed, 1)
		scheduled_bloc(classic_bloc, 27.50, 1, [-2.0, 3.0], default_speed, 1)
		scheduled_bloc(bomb_bloc, 30.75, 0, [0.0, 1.75], default_speed)
		scheduled_bloc(classic_bloc, 30.75, 0, [-2.0, 3.0], default_speed, 2)
		scheduled_bloc(classic_bloc, 30.75, 0, [2.0, 0.5], default_speed, 2)
		scheduled_bloc(bomb_bloc, 30.75, 1, [0.0, 1.75], default_speed)
		scheduled_bloc(classic_bloc, 30.75, 1, [2.0, 3.0], default_speed, 2)
		scheduled_bloc(classic_bloc, 30.75, 1, [-2.0, 0.5], default_speed, 2)
		scheduled_bloc(classic_bloc, 36.50, 0, [-2.0, 3.0], default_speed, 2)
		scheduled_bloc(classic_bloc, 36.50, 0, [2.0, 0.5], default_speed, 2)
		scheduled_bloc(classic_bloc, 36.50, 1, [2.0, 3.0], default_speed, 2)
		scheduled_bloc(classic_bloc, 36.50, 1, [-2.0, 0.5], default_speed, 2)
		scheduled_bloc(bonus_bloc, 40.25, 0, [0.0, 1.75], default_speed)
		scheduled_bloc(bomb_bloc, 40.25, 0, [-2.0, 0.5], default_speed)
		scheduled_bloc(bomb_bloc, 40.25, 0, [2.0, 3.0], default_speed)
		scheduled_bloc(bonus_bloc, 40.25, 1, [0.0, 1.75], default_speed)
		scheduled_bloc(bomb_bloc, 40.25, 1, [2.0, 0.5], default_speed)
		scheduled_bloc(bomb_bloc, 40.25, 1, [-2.0, 3.0], default_speed)
		scheduled_bloc(classic_bloc, 42.50, 0, [-2.0, 3.0], default_speed, 3)
		scheduled_bloc(classic_bloc, 42.50, 1, [-2.0, 0.5], default_speed, 3)
		scheduled_bloc(splash_bloc, 45.50, 0, [2.0, 3.0], default_speed, 2)
		scheduled_bloc(classic_bloc, 45.50, 0, [0.0, 0.5], default_speed, 1)
		scheduled_bloc(splash_bloc, 45.50, 1, [2.0, 1.75], default_speed)
		scheduled_bloc(classic_bloc, 47.00, 0, [-2.0, 3.0], default_speed, 2)
		scheduled_bloc(classic_bloc, 47.00, 1, [2.0, 3.0], default_speed, 2)
		scheduled_bloc(bomb_bloc, 48.50, 0, [-2.0, 0.5], default_speed)
		scheduled_bloc(bomb_bloc, 48.50, 0, [2.0, 3.0], default_speed)
		scheduled_bloc(bomb_bloc, 48.50, 1, [2.0, 0.5], default_speed)
		scheduled_bloc(bomb_bloc, 48.50, 1, [-2.0, 3.0], default_speed)
		
		default_speed *= 1.2
		scheduled_bloc(classic_bloc, 53.25, 0, [-2.0, 0.5], default_speed, 1)
		scheduled_bloc(classic_bloc, 53.25, 0, [2.0, 3.0], default_speed, 3)
		scheduled_bloc(classic_bloc, 53.25, 1, [2.0, 0.5], default_speed, 1)
		scheduled_bloc(classic_bloc, 53.25, 1, [-2.0, 3.0], default_speed, 3)
		scheduled_bloc(bomb_bloc, 57.25, 0, [0.0, 3.0], default_speed)
		scheduled_bloc(classic_bloc, 57.25, 0, [2.0, 0.5], default_speed, 1)
		scheduled_bloc(bomb_bloc, 57.25, 1, [0.0, 0.5], default_speed)
		scheduled_bloc(classic_bloc, 57.25, 1, [-2.0, 3.0], default_speed, 1)
		scheduled_bloc(classic_bloc, 59.50, 0, [-2.0, 3.0], default_speed, 3)
		scheduled_bloc(classic_bloc, 59.50, 1, [2.0, 3.0], default_speed, 3)
		scheduled_bloc(classic_bloc, 62.25, 1, [-2.0, 0.5], default_speed, 1)
		scheduled_bloc(classic_bloc, 62.25, 0, [-2.0, 3.0], default_speed, 3)
		scheduled_bloc(bomb_bloc, 66.00, 0, [0.0, 0.5], default_speed)
		scheduled_bloc(bomb_bloc, 66.00, 0, [2.0, 3.0], default_speed)
		scheduled_bloc(bomb_bloc, 66.00, 1, [0.0, 0.5], default_speed)
		scheduled_bloc(bomb_bloc, 66.00, 1, [-2.0, 3.0], default_speed)
		scheduled_bloc(classic_bloc, 67.25, 0, [-2.0, 3.0], default_speed, 3)
		scheduled_bloc(classic_bloc, 67.25, 0, [2.0, 0.5], default_speed, 3)
		scheduled_bloc(classic_bloc, 67.25, 1, [2.0, 3.0], default_speed, 3)
		scheduled_bloc(classic_bloc, 67.25, 1, [-2.0, 0.5], default_speed, 3)
		scheduled_bloc(bonus_bloc, 68.75, 0, [-2.0, 1.75], default_speed)
		scheduled_bloc(bonus_bloc, 68.75, 1, [2.0, 1.75], default_speed)

		# Phase 4
		default_speed /= 1.5
		scheduled_bloc(classic_bloc, 71.25, 0, [-2.0, 1.75], default_speed, 1)
		scheduled_bloc(classic_bloc, 71.25, 0, [2.0, 0.5], default_speed, 1)
		scheduled_bloc(classic_bloc, 71.25, 1, [2.0, 1.75], default_speed, 1)
		scheduled_bloc(classic_bloc, 71.25, 1, [-2.0, 0.5], default_speed, 1)
		scheduled_bloc(shield_bloc, 78.00, 0, [0.0, 1.75], default_speed)
		scheduled_bloc(shield_bloc, 78.00, 1, [0.0, 1.75], default_speed)
		scheduled_bloc(classic_bloc, 80.25, 0, [2.0, 3.0], default_speed, 2)
		scheduled_bloc(classic_bloc, 80.25, 1, [-2.0, 3.0], default_speed, 2)
		scheduled_bloc(classic_bloc, 83.75, 0, [0.0, 3.0], default_speed, 1)
		scheduled_bloc(classic_bloc, 83.75, 1, [0.0, 0.5], default_speed, 1)
		scheduled_bloc(bonus_bloc, 89.75, 0, [0.0, 1.75], default_speed)
		scheduled_bloc(bonus_bloc, 89.75, 1, [0.0, 1.75], default_speed)

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
	await get_tree().create_timer(delay_spawn_time, false).timeout
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
	bloc.striked_cube_j1.connect(func(b): _onStrikedBonusCube_j1(b))
	bloc.striked_cube_j2.connect(func(b): _onStrikedBonusCube_j2(b))
	spawn_valide(bloc, absolute_speed, direction, spawn)

func setup_bomb_bloc(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(_onStrikedBombCube_j1)
	bloc.striked_cube_j2.connect(_onStrikedBombCube_j2)
	spawn_valide(bloc, absolute_speed, direction, spawn)

func setup_disappear_bloc(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(func(b): _onStrikedDisappearCube_j1(b))
	bloc.striked_cube_j2.connect(func(b): _onStrikedDisappearCube_j2(b))
	spawn_valide(bloc, absolute_speed, direction, spawn, true)

func setup_splash_bloc(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(func(b): _onStrikedSplashCube_j1(b))
	bloc.striked_cube_j2.connect(func(b): _onStrikedSplashCube_j2(b))
	spawn_valide(bloc, absolute_speed, direction, spawn)

func setup_shield_bloc(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(func(b): _onStrikedShieldCube_j1(b))
	bloc.striked_cube_j2.connect(func(b): _onStrikedShieldCube_j2(b))
	spawn_valide(bloc, absolute_speed, direction, spawn)

func setup_heal_bloc(bloc: Node3D, absolute_speed: float, direction: int, spawn: Array[float]) -> void:
	# On connecte le bloc au spawner pour qu'il puisse être relié au score actuel
	bloc.striked_cube_j1.connect(func(b): _onStrikedHealCube_j1(b))
	bloc.striked_cube_j2.connect(func(b): _onStrikedHealCube_j2(b))
	spawn_valide(bloc, absolute_speed, direction, spawn)

func spawn_classic_replacement(pos: Vector3, speed: float) -> void:
	var bloc = generate_bloc(classic_bloc)
	# On place le cube à la position du cube frappé
	bloc.position = pos
	bloc.color = 1
	bloc.setup_color = true
	
	# On lui donne la vitesse renvoyée et on connecte les signaux
	bloc.vitesse_deplacement = speed
	bloc.striked_cube_j1.connect(_onStrikedClassicCube_j1)
	bloc.missed_cube_j1.connect(_onMissedClassicCube_j1)
	bloc.striked_cube_j2.connect(_onStrikedClassicCube_j2)
	bloc.missed_cube_j2.connect(_onMissedClassicCube_j2)
	
	# On désactive les collisions pendant 1 seconde pour éviter un hit immédiat
	bloc.get_node("CollisionShape3D").disabled = true
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(bloc): bloc.get_node("CollisionShape3D").disabled = false

func mode_with_sabers() -> bool:
	return (Global.launched_mode == 1) or (Global.launched_mode == 2)

func StrikedClassicCube(i: int) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 1000
	if Global.launched_mode % 2 == 0:
		score_uis[i].ajouter_score(gain)
		if Global.launched_mode == 2: score_uis[i+2].ajouter_score(gain)

func MissedClassicCube(i: int) -> void:
	if shield_actif[i] > 0:
		shield_actif[i] -= 1
		var current = shields[i].material_override.get_shader_parameter("MaskPower")
		shields[i].material_override.set_shader_parameter("MaskPower", current + 2.0)
		shield_bars[i].update_shield(shield_actif[i])
		if mode_with_sabers(): shield_bars[i+2].update_shield(shield_actif[i])
	else:
		multiplicateur[i] = 1
		stocked_combo[i] = 0
		if mode_with_sabers():
			texture_progress_bars[i].value = 0
			texture_progress_bars[i+2].value = 0
			texture_progress_bars[i].max_value = paliers[0]
			texture_progress_bars[i+2].max_value = paliers[0]
			progress_bar_labels[i].text = letters[0]
			progress_bar_labels[i+2].text = letters[0]
		if healing and Global.launched_mode == 2:
			health[i] -= 1
			health_bars[i].update_health(health[i])
			health_bars[i+2].update_health(health[i])

func StrikedBonusCube(i: int, bloc: Node3D) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 5000
	multiplicateur[i] *= 2
	count_bonus_time[i] = true
	if Global.launched_mode % 2 == 0:
		score_uis[i].ajouter_score(gain)
		if Global.launched_mode == 2: score_uis[i+2].ajouter_score(gain)
	spawn_classic_replacement(bloc.position, -bloc.vitesse_deplacement)
	if is_instance_valid(bloc): bloc.queue_free()

func StrikedBombCube(i: int) -> void:
	stocked_combo[i] = 0
	var gain = -500
	multiplicateur[i] = 1
	on_bomb_hit(i)
	if Global.launched_mode % 2 == 0:
		score_uis[i].ajouter_score(gain)
		hitted_bomb[i] = true
		if Global.launched_mode == 2: score_uis[i+2].ajouter_score(gain)

func StrikedDisappearCube(i: int, bloc: Node3D) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 15000
	multiplicateur[i] *= 2
	if Global.launched_mode % 2 == 0:
		score_uis[i].ajouter_score(gain)
		if Global.launched_mode == 2: score_uis[i+2].ajouter_score(gain)
	spawn_classic_replacement(bloc.position, -bloc.vitesse_deplacement)
	# On montre une notification au joueur pour lui dire qu'il a frappé le cube
	disappear_bloc_notif.visible = true
	await get_tree().create_timer(1.0).timeout
	disappear_bloc_notif.visible = false
	if is_instance_valid(bloc): bloc.queue_free()

func StrikedSplashCube(i: int, bloc: Node3D) -> void:
	stocked_combo[i] += 1
	var gain = multiplicateur[i] * 1000
	if Global.launched_mode % 2 == 0:
		score_uis[i].ajouter_score(gain)
		if Global.launched_mode == 2: score_uis[i+2].ajouter_score(gain)
	# On déclenche le visuel d'encre
	ink_overlay[i].trigger_ink()
	if Global.launched_mode == 2: ink_overlay[i+2].trigger_ink()
	spawn_classic_replacement(bloc.position, -bloc.vitesse_deplacement)
	if is_instance_valid(bloc): bloc.queue_free()

func StrikedShieldCube(i: int, bloc: Node3D) -> void:
	# On initialise la barre de vie, la durée et le visuel du bouclier
	spawn_classic_replacement(bloc.position, -bloc.vitesse_deplacement)
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
	if Global.launched_mode % 2 == 0:
		score_uis[i].ajouter_score(gain)
		if Global.launched_mode == 2: score_uis[i+2].ajouter_score(gain)
	if is_instance_valid(bloc): bloc.queue_free()

func StrikedHealCube(i: int, bloc: Node3D) -> void:
	health[i] += 1
	health_bars[i].update_health(health[i])
	health_bars[i+2].update_health(health[i])
	spawn_classic_replacement(bloc.position, -bloc.vitesse_deplacement)

func _onStrikedClassicCube_j1() -> void:
	StrikedClassicCube(0)

func _onMissedClassicCube_j1() -> void:
	MissedClassicCube(0)

func _onStrikedClassicCube_j2() -> void:
	StrikedClassicCube(1)

func _onMissedClassicCube_j2() -> void:
	MissedClassicCube(1)

func _onStrikedBonusCube_j1(bloc: Node3D) -> void:
	StrikedBonusCube(0, bloc)

func _onStrikedBonusCube_j2(bloc: Node3D) -> void:
	StrikedBonusCube(1, bloc)

func _onStrikedBombCube_j1(bloc: Node3D) -> void:
	StrikedBombCube(0)
	bloc.queue_free()

func _onStrikedBombCube_j2(bloc: Node3D) -> void:
	StrikedBombCube(1)
	bloc.queue_free()

func _onStrikedDisappearCube_j1(bloc: Node3D) -> void:
	StrikedDisappearCube(0, bloc)

func _onStrikedDisappearCube_j2(bloc: Node3D) -> void:
	StrikedDisappearCube(1, bloc)

func _onStrikedSplashCube_j1(bloc: Node3D) -> void:
	StrikedSplashCube(0, bloc)

func _onStrikedSplashCube_j2(bloc: Node3D) -> void:
	StrikedSplashCube(1, bloc)

func _onStrikedShieldCube_j1(bloc: Node3D) -> void:
	StrikedShieldCube(0, bloc)

func _onStrikedShieldCube_j2(bloc: Node3D) -> void:
	StrikedShieldCube(1, bloc)

func _onStrikedHealCube_j1(bloc: Node3D) -> void:
	StrikedHealCube(0, bloc)

func _onStrikedHealCube_j2(bloc: Node3D) -> void:
	StrikedHealCube(1, bloc)
