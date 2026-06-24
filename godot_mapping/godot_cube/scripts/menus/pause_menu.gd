extends ColorRect
@onready var menu_buttons: Panel = $MenuButtons
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var options: Panel = $Options
@onready var calibration: Panel = $CalibrationSaber
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

@onready var switch_game_button: Button = $MenuButtons/SwitchGameButton
@onready var sign_switch_game: Sprite2D = $MenuButtons/SignSwitchGame
var switch_scale: Vector2
var sign_switch_scale: Vector2

@onready var sign_cal_change: Sprite2D = $Options/SignCalChange
@onready var cal_change_button: Button = $Options/CalChange
var cal_change_scale: Vector2
var sign_cal_change_scale: Vector2

@onready var sign_cal_back: Sprite2D = $CalibrationSaber/SignBack
@onready var cal_back_button: Button = $CalibrationSaber/BackButton
var cal_back_scale: Vector2
var sign_cal_back_scale: Vector2

# Cadres du tutoriel
var cadres: Panel
# Liste des barres de combo visuelles
var combo_bar_list: Array[Control] = []
# Infos techniques du jeu et labels annexes
var technical_infos: CanvasLayer
@onready var start_label: Label = $"../../StartLabel"
@onready var disappear_bloc_notif: Label = $"../../DisappearBlocNotif"

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
	cal_back_scale = cal_back_button.scale
	sign_cal_back_scale = sign_cal_back.scale
	switch_scale = switch_game_button.scale
	sign_switch_scale = sign_switch_game.scale
	cal_change_scale = cal_change_button.scale
	sign_cal_change_scale = sign_cal_change.scale
	
	if Global.launched_mode == 2: technical_infos = $"../../../TechnicalInfos"
	
	if Global.launched_mode < 4:
		# Récupération de toutes les barres de combo visuelles
		var combo_bar_vue1 = get_node_or_null("../../../J1/CameraController/Vue1/ComboBar")
		var combo_bar_vue2 = get_node_or_null("../../../J1/CameraController/Vue2/ComboBar")
		var combo_bar_vue5 = get_node_or_null("../../../J2/CameraController/Vue5/ComboBar")
		var combo_bar_vue6 = get_node_or_null("../../../J2/CameraController/Vue6/ComboBar")
		combo_bar_list = [combo_bar_vue1, combo_bar_vue2, combo_bar_vue5, combo_bar_vue6]
	material.set_shader_parameter("lod", 0.0)

func _process(delta: float) -> void:
	latence_pause += delta
	if Global.launched_mode == 1:
		if not Global.setup_tutoriel:
			sign_switch_game.visible = false
			switch_game_button.visible = false
			sign_mode.visible = true
			mode_button.visible = true
		else:
			sign_mode.visible = false
			mode_button.visible = false
			sign_switch_game.visible = true
			switch_game_button.visible = true
	else:
		sign_switch_game.visible = false
		switch_game_button.visible = false
		sign_mode.visible = false
		mode_button.visible = false
		sign_menu.position = Vector2(310.0, 460.0)
		main_menu_button.position = Vector2(220.0, 440.0)
		sign_quit.position = Vector2(310.0, 590.0)
		quit_button.position = Vector2(272.5, 570.0)

func transition(appear_list: Array[Control], disappear_list: Array[Control]) -> void:
	# Effectue une transition courante entre 2 pages du menu
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var t = create_tween().set_parallel(true)
	for panel in disappear_list:
		t.tween_property(panel, "modulate:a", 0.0, 0.1)
	t.set_parallel(false)
	t.chain().tween_interval(0.1)
	t.tween_callback(func():
		for panel in disappear_list:
			panel.visible = false
		if appear_list == []:
			fondu_noir.modulate.a = 0.0
			fondu_noir.visible = true
		else:
			for panel in appear_list:
				panel.modulate.a = 0.0
				panel.visible = true)
	t.set_parallel(true)
	if appear_list == []:
		# Il y a un changement de scène, donc, on fait un fondu.
		t.set_parallel(false)
		t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
		if options not in disappear_list: t.tween_property(GlobalMusic, "volume_db", -80.0, 0.8)
		t.chain().tween_interval(0.3)
	else:
		for panel in appear_list:
			t.tween_property(panel, "modulate:a", 1.0, 0.1)
		t.set_parallel(false)
	await t.finished

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
		if is_instance_valid(technical_infos): technical_infos.visible = false
		start_label.visible = false
		disappear_bloc_notif.visible = false
		# On s'assure que tout est visible avant d'animer
		menu_buttons.visible = true
		
		var t = create_tween()
		t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		t.parallel().tween_property(menu_buttons, "modulate:a", 1.0, 0.1)
		
		# On fait monter les panneaux
		if cadres:
			if cadres.visible:
				t.set_ease(Tween.EASE_OUT)
				t.set_trans(Tween.TRANS_BACK)
				t.parallel().tween_property(cadres, "position", Vector2(0.0, 0.0), 0.8)
		t.set_ease(Tween.EASE_IN_OUT)
		for combo_bar in combo_bar_list:
			if is_instance_valid(combo_bar):
				t.parallel().tween_property(combo_bar, "modulate:a", 0.0, 0.1)
		t.parallel().tween_method(set_blur_intensity, 0.0, 2.0, 0.1)
		await t.finished
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		_onContinueButton_pressed()

func _onContinueButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var t = create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(menu_buttons, "modulate:a", 0.0, 0.1)
	t.chain().tween_interval(0.3)
	t.parallel().tween_method(set_blur_intensity, 2.0, 0.0, 0.1)
	
	# On fait redescendre les panneaux
	if cadres:
		if cadres.visible:
			t.set_ease(Tween.EASE_OUT)
			t.set_trans(Tween.TRANS_BACK)
			t.parallel().tween_property(cadres, "position", Vector2(0.0, 700.0), 0.8)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			landmarks_proceed.camera_feed.feed_is_active = false
		else:
			for combo_bar in combo_bar_list:
				t.parallel().tween_property(combo_bar, "modulate:a", 1.0, 0.1)
	await t.finished
	
	latence_pause = 0.0
	menu_buttons.visible = false
	technical_infos.visible = true
	start_label.visible = true
	disappear_bloc_notif.visible = true
	on_option_menu = false
	affichage = false
	if cadres:
		if not cadres.visible:
			get_tree().paused = false
			landmarks_proceed.camera_feed.feed_is_active = true
	else:
		get_tree().paused = false
		landmarks_proceed.camera_feed.feed_is_active = true

func _onOptionButton_pressed() -> void:
	on_option_menu = true
	transition([options], [menu_buttons])
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onModeButton_pressed() -> void:
	click_sound.play()
	cadres.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var t = create_tween().set_parallel(true)
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(menu_buttons, "modulate:a", 0.0, 0.1)
	t.set_parallel(false)
	t.chain().tween_interval(0.3)
	t.parallel().tween_method(set_blur_intensity, 2.0, 0.0, 0.1)
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_BACK)
	t.parallel().tween_property(cadres, "position", Vector2(0.0, 700.0), 0.8)
	await t.finished
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Le tutoriel est arrêté, donc, il faut refaire le setup
	Global.setup_tutoriel = true
	latence_pause = 0.0
	menu_buttons.visible = false
	on_option_menu = false
	affichage = false

func _onQuitButton_pressed() -> void:
	await transition([], [menu_buttons])
	get_tree().quit()

func _onBackButton_pressed() -> void:
	transition([menu_buttons], [options])
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	on_option_menu = false

func _onMainMenuButton_pressed() -> void:	
	await transition([], [menu_buttons])
	Global.launched_mode = 0
	get_tree().change_scene_to_file("res://scenes/menus/main_menu_3d.tscn")

func _onSwitchGameButton_pressed() -> void:
	await transition([], [menu_buttons])
	Global.launched_mode = 2
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/game_scenes/scene_TV.tscn")

func _onCameraButton_pressed() -> void :
	landmarks_proceed.reload_camera_selection()

func _onCalChangeButton_pressed() -> void:
	Global.is_camera_visible = true
	transition([calibration], [options])
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onBackCalButton_pressed() -> void:
	transition([options], [calibration])
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

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

func _onSwitchGameButtonEnter() -> void:
	Global.ButtonEnter(switch_game_button, switch_scale, false, sign_switch_game, sign_switch_scale)

func _onSwitchGameButtonExit() -> void:
	Global.ButtonExit(switch_game_button, switch_scale)

func _onCalChangeButtonEnter() -> void:
	Global.is_camera_visible = true
	Global.ButtonEnter(cal_change_button, cal_change_scale, false, sign_cal_change, sign_cal_change_scale)

func _onCalChangeButtonExit() -> void:
	Global.ButtonExit(cal_change_button, cal_change_scale, false, sign_cal_change, sign_cal_change_scale)

func _onBackCalButtonEnter() -> void:
	Global.ButtonEnter(cal_back_button, cal_back_scale, false, sign_cal_back, sign_cal_back_scale)

func _onBackCalButtonExit() -> void:
	Global.is_camera_visible = false
	Global.ButtonExit(cal_back_button, cal_back_scale, false, sign_cal_back, sign_cal_back_scale)
	
# Valeurs de l'étirement maximal des sabres sur l'écran
func _onAlpha1Changed(value: float) -> void:
	Global.alpha1 = value

func _onMidx1Changed(value: float) -> void:
	Global.midx1 = value
	
func _onBeta1Changed(value: float) -> void:
	Global.beta1 = value
	
func _onMidy1Changed(value: float) -> void:
	Global.midy1 = value

func _onAlpha2Changed(value: float) -> void:
	Global.alpha2 = value
	
func _onMidx2Changed(value: float) -> void:
	Global.midx2 = value
	
func _onBeta2Changed(value: float) -> void:
	Global.beta2 = value
	
func _onMidy2Changed(value: float) -> void:
	Global.midy2 = value
