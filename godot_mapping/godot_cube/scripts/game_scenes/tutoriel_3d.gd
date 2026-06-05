extends Node3D

@export var nb_views : int = 8
@onready var screen_output = $TextureRect
@onready var game: Node3D = $Game

@onready var remote1_j1: RemoteTransform3D = $J1/CameraController/RemoteVue1
@onready var remote2_j1: RemoteTransform3D = $J1/CameraController/RemoteVue2
@onready var remote1_j2: RemoteTransform3D = $J2/CameraController/RemoteVue5
@onready var remote2_j2: RemoteTransform3D = $J2/CameraController/RemoteVue6

@onready var combo_bar_vue1 = $J1/CameraController/Vue1/ComboBar
@onready var combo_bar_vue2 = $J1/CameraController/Vue2/ComboBar
@onready var combo_bar_vue5 = $J2/CameraController/Vue5/ComboBar
@onready var combo_bar_vue6 = $J2/CameraController/Vue6/ComboBar
var combo_bar_list: Array[Control] = []

@onready var cadres: Panel = $Cadres
@onready var pause_menu: ColorRect = $Game/HUD/PauseMenu
@onready var click_sound: AudioStreamPlayer = $Game/HUD/PauseMenu/ClickSound

var rd: RenderingDevice
var last_gpu_time_ms: float = 0.0
var last_gpu_vues_ms: float = 0.0

func _ready() -> void:
	Global.launched_mode = 1
	# On masque les barres de combo hors du jeu
	combo_bar_list = [combo_bar_vue1, combo_bar_vue2, combo_bar_vue5, combo_bar_vue6]
	for combo_bar in combo_bar_list:
		combo_bar.modulate.a = 0.0

	rd = RenderingServer.get_rendering_device()
	await get_tree().process_frame
	# On récupère le monde 3D
	var world_3d = get_viewport().world_3d
	if has_node("Game"):
		world_3d = game.get_world_3d()
	
	var shader_mat = screen_output.material as ShaderMaterial
	# On configure chaque vue
	for i in range(1, nb_views+1):
		var viewport_vue
		if i == 1 or i == 2 :
			viewport_vue = "J1/CameraController/Vue" + str(i)
		elif i == 5 or i == 6:
			viewport_vue = "J2/CameraController/Vue" + str(i)
		else:
			viewport_vue = "Vue" + str(i)
		if has_node(viewport_vue):
			var vue = get_node(viewport_vue) as SubViewport
			vue.world_3d = world_3d # On met en commun le monde 3D
			await get_tree().process_frame # On attend un court instant pour l'initialisation de la texture
			var texture_vue = vue.get_texture()
			var shader_vue = "vue_" + str(i)
			shader_mat.set_shader_parameter(shader_vue, texture_vue)
	screen_output.material.set_shader_parameter("offset", 0.0) # Initialise l'effet glitch à 0
	screen_output.material.set_shader_parameter("pixelisation_mask", [true, true, false, false, true, true, false, false]) # Initialise les vues qui auront l'effet de pixelisation
	welcoming_tuto()

func welcoming_tuto() -> void:
	# On initialise les cadres dans le cas où on fait apparaître le menu de pause
	pause_menu.cadres = cadres
	get_tree().paused = true
	
	# On fait descendre les panneaux
	var t = create_tween().set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_BACK)
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(cadres, "position", Vector2(0.0, 700.0), 0.8)
	await t.finished
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(_delta: float) -> void:
	# On contrôle le décalage de positions entre les caméras de chacun des joueurs
	var step : float = 0.01
	if Input.is_action_just_pressed("BringCloserCamJ1"):
		remote1_j1.position.x += step
		remote2_j1.position.x -= step
	elif Input.is_action_just_pressed("MoveAwayCamJ1"):
		remote1_j1.position.x -= step
		remote2_j1.position.x += step
	elif Input.is_action_just_pressed("BringCloserCamJ2"):
		remote1_j2.position.x += step
		remote2_j2.position.x -= step
	elif Input.is_action_just_pressed("MoveAwayCamJ2"):
		remote1_j2.position.x -= step
		remote2_j2.position.x += step

func monte_cadres() -> void:
	# On fait monter les panneaux
	var t = create_tween().set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_BACK)
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(cadres, "position", Vector2(0.0, 0.0), 0.8)
	await t.finished
	cadres.visible = false
	Global.setup_tutoriel = true

func appear_combos() -> void:
	var t = create_tween().set_parallel(true)
	for combo_bar in combo_bar_list:
		t.tween_property(combo_bar, "modulate:a", 1.0, 0.1)
	await t.finished

func _onClassicButton_pressed() -> void:
	click_sound.play()
	monte_cadres()
	await get_tree().create_timer(0.5).timeout
	Global.tutoriel_played_mode = 0
	appear_combos()
	get_tree().paused = false

func _onBonusButton_pressed() -> void:
	click_sound.play()
	monte_cadres()
	await get_tree().create_timer(0.5).timeout
	Global.tutoriel_played_mode = 1
	appear_combos()
	get_tree().paused = false

func _onCBButton_pressed() -> void:
	click_sound.play()
	monte_cadres()
	await get_tree().create_timer(0.5).timeout
	Global.tutoriel_played_mode = 2
	appear_combos()
	get_tree().paused = false

func _onAllButton_pressed() -> void:
	click_sound.play()
	monte_cadres()
	await get_tree().create_timer(0.5).timeout
	Global.tutoriel_played_mode = 3
	appear_combos()
	get_tree().paused = false
