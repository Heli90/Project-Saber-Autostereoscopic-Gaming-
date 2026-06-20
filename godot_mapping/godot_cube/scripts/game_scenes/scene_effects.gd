extends Node3D

@export var nb_views : int = 8
@onready var screen_output = $TextureRect
@onready var game: Node3D = $Game
@onready var cube_spawner: Node3D = $Game/CubeSpawner
@onready var fondu_noir: ColorRect = $Game/HUD/FonduLayer/FonduNoir
@onready var landmarks_proceed: Node2D = $Game/LandMarksProceed
@onready var pause_menu: ColorRect = $Game/HUD/PauseMenu
@onready var click_sound: AudioStreamPlayer = $Game/HUD/PauseMenu/ClickSound

@onready var camera1: Camera3D = $Vue1/Camera
@onready var camera2: Camera3D = $Vue2/Camera
@onready var camera3: Camera3D = $Vue5/Camera
@onready var camera4: Camera3D = $Vue6/Camera
var array_cam: Array[Camera3D]

@onready var cadre: Panel = $Cadre
@onready var label: Label = $Cadre/Label
@onready var line: Line2D = $Cadre/Line2D
@onready var ok_button: Button = $Cadre/Buttons/OKButton
@onready var continue_button: Button = $Cadre/Buttons/ContinueButton
@onready var stop_button: Button = $Cadre/Buttons/StopButton
var ok_scale: Vector2
var continue_scale: Vector2
var stop_scale: Vector2

func _ready() -> void:
	# Initialisation des tailles des boutons pour les effets
	ok_scale = ok_button.scale
	continue_scale = continue_button.scale
	stop_scale = stop_button.scale
	
	# Définition de la liste des caméras et des positions initiales
	array_cam = [camera1, camera3, camera2, camera4]
	for i in range(4): array_cam[i].position.x = Global.array_cam[i]
	
	# On ne lance pas le thread de caméra au début pour optimiser les FPS
	landmarks_proceed.camera_feed.feed_is_active = false
	
	# On récupère le monde 3D
	var world_3d = get_viewport().world_3d
	if has_node("Game"):
		world_3d = game.get_world_3d()
	
	var shader_mat = screen_output.material as ShaderMaterial
	# On configure chaque vue
	for i in range(1, nb_views+1):
		var viewport_vue = "Vue" + str(i)
		if has_node(viewport_vue):
			var vue = get_node(viewport_vue) as SubViewport
			vue.world_3d = world_3d # On met en commun le monde 3D
			await get_tree().process_frame # On attend un court instant pour l'initialisation de la texture
			var texture_vue = vue.get_texture()
			var shader_vue = "vue_" + str(i)
			shader_mat.set_shader_parameter(shader_vue, texture_vue)
	screen_output.material.set_shader_parameter("offset", 0.0) # Initialise l'effet glitch à 0
	screen_output.material.set_shader_parameter("pixelisation_mask", [true, true, false, false, true, true, false, false]) # Initialise les vues qui auront l'effet de pixelisation
	await get_tree().process_frame
	screen_output.material.set_shader_parameter("intensity_color", 0.0)

	var t = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(fondu_noir, "modulate:a", 0.0, 0.6)
	await t.finished
	fondu_noir.visible = false
	welcoming_effects()

func welcoming_effects() -> void:
	# On initialise les cadres dans le cas où on fait apparaître le menu de pause
	pause_menu.cadres = cadre
	get_tree().paused = true
	
	# On fait descendre les panneaux
	var t = create_tween().set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_BACK)
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(cadre, "position", Vector2(0.0, 700.0), 0.8)
	await t.finished
	await get_tree().create_timer(0.5).timeout
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float) -> void:
	if cube_spawner.stop_loop_in_effect_map:
		get_tree().paused = true
		descend_cadre()

func monte_cadre() -> void:
	# On fait monter les panneaux
	var t = create_tween()
	t.set_trans(Tween.TRANS_BACK)
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(cadre, "position", Vector2(0.0, 0.0), 0.8)
	await t.finished
	cadre.visible = false

func descend_cadre() -> void:
	# On fait descendre les panneaux
	var t = create_tween().set_ease(Tween.EASE_OUT)
	cadre.visible = true
	t.set_trans(Tween.TRANS_BACK)
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(cadre, "position", Vector2(0.0, 700.0), 0.8)
	await t.finished
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onOKButton_pressed() -> void:
	click_sound.play()
	monte_cadre()
	await get_tree().create_timer(0.5).timeout
	# On change le cadre pour les prochaines fois
	ok_button.visible = false
	continue_button.visible = true
	stop_button.visible = true
	line.visible = true
	cube_spawner.start_loop_in_effect_map = true
	label.text = "Do you want to repeat\nthe experience ?"
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false

func _onContinueButton_pressed() -> void:
	click_sound.play()
	cube_spawner.is_effect_cube_generated = false
	cube_spawner.blocs[0].queue_free()
	cube_spawner.rebonds = 0
	monte_cadre()
	cube_spawner.last_effect_applied_time = 0.0
	cube_spawner.start_loop_in_effect_map = true
	cube_spawner.stop_loop_in_effect_map = false
	await get_tree().create_timer(0.5).timeout
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false

func _onStopButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	monte_cadre()
	var t = create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.chain().tween_interval(0.1)
	t.tween_callback(func():
		fondu_noir.modulate.a = 0.0
		fondu_noir.visible = true)
	t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	t.chain().tween_interval(0.3)
	await t.finished
	get_tree().paused = false
	Global.launched_mode = 0
	get_tree().change_scene_to_file("res://scenes/menus/main_menu_3d.tscn")

func _onOKButtonEnter() -> void:
	Global.ButtonEnter(ok_button, ok_scale)

func _onOKButtonExit() -> void:
	Global.ButtonExit(ok_button, ok_scale)

func _onContinueButtonEnter() -> void:
	Global.ButtonEnter(continue_button, ok_scale)

func _onContinueButtonExit() -> void:
	Global.ButtonExit(continue_button, ok_scale)

func _onStopButtonEnter() -> void:
	Global.ButtonEnter(stop_button, stop_scale)

func _onStopButtonExit() -> void:
	Global.ButtonExit(stop_button, stop_scale)
