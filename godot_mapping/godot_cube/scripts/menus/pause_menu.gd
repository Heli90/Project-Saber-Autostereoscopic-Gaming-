extends ColorRect
@onready var menu_buttons: Panel = $MenuButtons
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var options: Panel = $Options
@onready var fondu_noir: ColorRect = $FonduNoir
@onready var landmarks_proceed = $"../../LandMarksProceed"
@onready var select_camera: ConfirmationDialog = $"../../LandMarksProceed/SelectCamera"

@onready var continue_button: Button = $MenuButtons/ContinueButton
@onready var sign_continue: Sprite2D = $MenuButtons/SignContinue
var continue_scale: Vector2
var sign_continue_scale: Vector2

@onready var option_button: Button = $MenuButtons/OptionButton
@onready var sign_option: Sprite2D = $MenuButtons/SignOption
var option_scale: Vector2
var sign_option_scale: Vector2

@onready var mode_button: Button = $MenuButtons/ModeButton
@onready var sign_mode: Sprite2D = $MenuButtons/SignMode
var mode_scale: Vector2
var sign_mode_scale: Vector2

@onready var main_menu_button: Button = $MenuButtons/MainMenuButton
@onready var sign_menu: Sprite2D = $MenuButtons/SignMenu
var menu_scale: Vector2
var sign_menu_scale: Vector2

@onready var quit_button: Button = $MenuButtons/QuitButton
@onready var sign_quit: Sprite2D = $MenuButtons/SignQuit
var quit_scale: Vector2
var sign_quit_scale: Vector2

@onready var camera_button: Button = $Options/CameraButton
@onready var sign_camera: Sprite2D = $Options/SignCamera
var camera_scale: Vector2
var sign_camera_scale: Vector2

@onready var back_button: Button = $Options/BackButton
@onready var sign_back: Sprite2D = $Options/SignBack
var back_scale: Vector2
var sign_back_scale: Vector2

# Cadres du tutoriel
var cadres: Panel
# Liste des barres de combo visuelles
var combo_bar_list: Array[Control] = []

static var affichage: bool
static var on_option_menu: bool
var test_button_is_pressed : bool = false
var latence_pause: float = 0.0

func _ready() -> void:
	# On s'assure que tous les boutons sont invisibles au début du jeu
	menu_buttons.modulate.a = 0.0
	options.modulate.a = 0.0
	on_option_menu = false
	affichage = false
	menu_buttons.visible = false
	options.visible = false
	fondu_noir.visible = false
	
	# Définition de la taille de tous les boutons et de tous les panneaux
	continue_scale = continue_button.scale
	sign_continue_scale = sign_continue.scale
	option_scale = option_button.scale
	sign_option_scale = sign_option.scale
	quit_scale = quit_button.scale
	sign_quit_scale = sign_quit.scale
	mode_scale = mode_button.scale
	sign_mode_scale = sign_mode.scale
	menu_scale = main_menu_button.scale
	sign_menu_scale = sign_menu.scale
	camera_scale = camera_button.scale
	sign_camera_scale = sign_camera.scale
	back_scale = back_button.scale
	sign_back_scale = sign_back.scale
	
	# Récupération de toutes les barres de combo visuelles dans le cas du tutoriel
	var combo_bar_vue1 = get_node_or_null("../../../J1/CameraController/Vue1/ComboBar")
	var combo_bar_vue2 = get_node_or_null("../../../J1/CameraController/Vue2/ComboBar")
	var combo_bar_vue5 = get_node_or_null("../../../J2/CameraController/Vue5/ComboBar")
	var combo_bar_vue6 = get_node_or_null("../../../J2/CameraController/Vue6/ComboBar")
	combo_bar_list = [combo_bar_vue1, combo_bar_vue2, combo_bar_vue5, combo_bar_vue6]
	material.set_shader_parameter("lod", 0.0)

func _process(delta: float) -> void:
	latence_pause += delta
	if not Global.setup_tutoriel:
		sign_mode.visible = true
		mode_button.visible = true
		
		sign_menu.position = Vector2(310.0, 590.0)
		main_menu_button.position = Vector2(220.0, 570.0)
		sign_quit.position = Vector2(310.0, 720.0)
		quit_button.position = Vector2(272.5, 700.0)
	else:
		sign_mode.visible = false
		mode_button.visible = false
		
		sign_menu.position = Vector2(310.0, 460.0)
		main_menu_button.position = Vector2(220.0, 440.0)
		sign_quit.position = Vector2(310.0, 590.0)
		quit_button.position = Vector2(272.5, 570.0)

func _input(event: InputEvent) -> void:
	# On vérifie l'appui de Echap ainsi que le respect du temps de latence et d'animation
	var appui_synchro: bool = event.is_action_pressed("Menu") and latence_pause > 0.75 and (not on_option_menu)
	if appui_synchro and Global.launched_mode > 0:
		latence_pause = 0.0
		landmarks_proceed.camera_feed.feed_is_active = false
		get_viewport().set_input_as_handled()
		toggle_pause()

func set_blur_intensity(value: float):
	material.set_shader_parameter("lod", value)

func toggle_pause():
	if (not affichage):
		affichage = true
		get_tree().paused = true
		# On s'assure que tout est visible avant d'animer
		menu_buttons.visible = true
		
		var transition = create_tween()
		transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		transition.parallel().tween_property(menu_buttons, "modulate:a", 1.0, 0.1)
		
		# On fait monter les panneaux
		if cadres:
			if cadres.visible:
				transition.set_ease(Tween.EASE_OUT)
				transition.set_trans(Tween.TRANS_BACK)
				transition.parallel().tween_property(cadres, "position", Vector2(0.0, 0.0), 0.8)
		transition.set_ease(Tween.EASE_IN_OUT)
		transition.parallel().tween_method(set_blur_intensity, 0.0, 2.0, 0.1)
		await transition.finished
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		_onContinueButton_pressed()

func _onContinueButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var transition = create_tween()
	transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	transition.tween_property(menu_buttons, "modulate:a", 0.0, 0.1)
	transition.chain().tween_interval(0.3)
	transition.parallel().tween_method(set_blur_intensity, 2.0, 0.0, 0.1)
	
	# On fait redescendre les panneaux
	if cadres:
		if cadres.visible:
			transition.set_ease(Tween.EASE_OUT)
			transition.set_trans(Tween.TRANS_BACK)
			transition.parallel().tween_property(cadres, "position", Vector2(0.0, 700.0), 0.8)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await transition.finished
	
	latence_pause = 0.0
	menu_buttons.visible = false
	on_option_menu = false
	affichage = false
	landmarks_proceed.camera_feed.feed_is_active = true
	if cadres:
		if not cadres.visible: get_tree().paused = false
	else:
		get_tree().paused = false

func _onOptionButton_pressed() -> void:
	on_option_menu = true
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var transition = create_tween().set_parallel(true)
	transition.tween_property(menu_buttons, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		options.modulate.a = 0.0
		menu_buttons.visible = false
		options.visible = true)
	transition.tween_property(options, "modulate:a", 1.0, 0.1)
	await transition.finished
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onModeButton_pressed() -> void:
	click_sound.play()
	cadres.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var transition = create_tween().set_parallel(true)
	transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for combo_bar in combo_bar_list:
		transition.tween_property(combo_bar, "modulate:a", 0.0, 0.1)
	transition.tween_property(menu_buttons, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.3)
	transition.parallel().tween_method(set_blur_intensity, 2.0, 0.0, 0.1)
	transition.set_ease(Tween.EASE_OUT)
	transition.set_trans(Tween.TRANS_BACK)
	transition.parallel().tween_property(cadres, "position", Vector2(0.0, 700.0), 0.8)
	await transition.finished
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Le tutoriel est arrêté, donc, il faut refaire le setup
	Global.setup_tutoriel = true
	latence_pause = 0.0
	menu_buttons.visible = false
	on_option_menu = false
	affichage = false

func _onQuitButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var transition = create_tween().set_parallel(true)
	transition.tween_property(menu_buttons, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		fondu_noir.modulate.a = 0.0
		fondu_noir.visible = true)
	transition.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	transition.chain().tween_interval(0.3)
	await transition.finished
	get_tree().quit()

func _onBackButton_pressed() -> void:
	click_sound.play()
	for button in menu_buttons.get_children(): # On annule le spam d'appui de boutonss
		if button is Button: button.disabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var transition = create_tween().set_parallel(true)
	transition.tween_property(options, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		menu_buttons.visible = true
		options.visible = false)
	transition.set_parallel(true)
	
	# On remet tous les textes en noir pour éviter un flash à l'écran
	for button in menu_buttons.get_children():
		if button is Button: button.modulate = Color.BLACK
	
	transition.tween_property(menu_buttons, "modulate:a", 1.0, 0.1)
	transition.chain()
	await transition.finished
	
	for button in menu_buttons.get_children(): # On annule le spam d'appui de boutons
		if button is Button: button.disabled = false
	# On remet la couleur initiale lorsque le curseur passe sur un bouton
	for button in menu_buttons.get_children():
		if button is Button: button.modulate = Color.WHITE
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	on_option_menu = false

func _onMainMenuButton_pressed() -> void:	
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var transition = create_tween().set_parallel(true)
	transition.tween_property(menu_buttons, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		fondu_noir.modulate.a = 0.0
		fondu_noir.visible = true)
	transition.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	transition.chain().tween_interval(0.3)
	await transition.finished
	Global.launched_mode = 0
	get_tree().change_scene_to_file("res://scenes/menus/main_menu_3d.tscn")

func _onCameraButton_pressed() -> void :
	landmarks_proceed.reload_camera_selection()

func _onContinueButtonEnter() -> void:
	Global.ButtonEnter(continue_button, continue_scale, false, sign_continue, sign_continue_scale)

func _onContinueButtonExit() -> void:
	Global.ButtonExit(continue_button, continue_scale)

func _onOptionButtonEnter() -> void:
	Global.ButtonEnter(option_button, continue_scale, false, sign_option, sign_option_scale)

func _onOptionButtonExit() -> void:
	Global.ButtonExit(option_button, option_scale)

func _onMenuButtonEnter() -> void:
	Global.ButtonEnter(main_menu_button, menu_scale, false, sign_menu, sign_menu_scale)

func _onMenuButtonExit() -> void:
	Global.ButtonExit(main_menu_button, menu_scale)

func _onQuitButtonEnter() -> void:
	Global.ButtonEnter(quit_button, quit_scale, false, sign_quit, sign_quit_scale)

func _onQuitButtonExit() -> void:
	Global.ButtonExit(quit_button, quit_scale)

func _onCameraButtonEnter() -> void:
	Global.ButtonEnter(camera_button, camera_scale, false, sign_camera, sign_camera_scale)

func _onCameraButtonExit() -> void:
	Global.ButtonExit(camera_button, camera_scale)

func _onBackButtonEnter() -> void:
	Global.ButtonEnter(back_button, back_scale, false, sign_back, sign_back_scale)

func _onBackButtonExit() -> void:
	Global.ButtonExit(back_button, back_scale)

func _onModeButtonEnter() -> void:
	Global.ButtonEnter(mode_button, mode_scale, false, sign_mode, sign_mode_scale)

func _onModeButtonExit() -> void:
	Global.ButtonExit(mode_button, mode_scale)
