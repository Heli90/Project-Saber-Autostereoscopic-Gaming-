extends Node3D

@export var nb_views : int = 8
@onready var screen_output = $TextureRect
@onready var game: Node3D = $Game
@onready var fondu_noir: ColorRect = $Game/HUD/FonduLayer/FonduNoir
@onready var landmarks_proceed: Node2D = $Game/LandMarksProceed
@onready var pause_menu: ColorRect = $Game/HUD/PauseMenu
@onready var click_sound: AudioStreamPlayer = $Game/HUD/PauseMenu/ClickSound

@onready var cadre: Panel = $Cadre
@onready var label: Label = $Cadre/Label
@onready var ok_button: Button = $Cadre/Buttons/OKButton
@onready var continue_button: Button = $Cadre/Buttons/ContinueButton
@onready var stop_button: Button = $Cadre/Buttons/StopButton
var ok_scale: Vector2
var continue_scale: Vector2
var stop_scale: Vector2

func _ready() -> void:
	fondu_noir.visible = false
	# Initialisation des tailles des boutons pour les effets
	ok_scale = ok_button.scale
	continue_scale = continue_button.scale
	stop_scale = stop_button.scale
	
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
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func monte_cadre() -> void:
	# On fait monter les panneaux
	var t = create_tween().set_ease(Tween.EASE_IN_OUT)
	t.set_trans(Tween.TRANS_BACK)
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(cadre, "position", Vector2(0.0, 0.0), 0.8)
	await t.finished
	cadre.visible = false

func _onOKButton_pressed() -> void:
	click_sound.play()
	monte_cadre()
	await get_tree().create_timer(0.5).timeout
	# On change le cadre pour les prochaines fois
	ok_button.visible = false
	continue_button.visible = true
	stop_button.visible = true
	label.text = "Do you want to repeat\nthe experience ?"
	get_tree().paused = false

func _onContinueButton_pressed() -> void:
	click_sound.play()
	monte_cadre()
	await get_tree().create_timer(0.5).timeout
	get_tree().paused = false

func _onStopButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	monte_cadre()
	var transition = create_tween()
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		fondu_noir.modulate.a = 0.0
		fondu_noir.visible = true)
	transition.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	transition.chain().tween_interval(0.3)
	await transition.finished
	get_tree().paused = false
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
