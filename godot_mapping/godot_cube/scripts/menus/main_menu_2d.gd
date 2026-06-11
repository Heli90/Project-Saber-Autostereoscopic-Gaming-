extends Control

@onready var main_buttons: Panel = $MainButtons
@onready var options: Panel = $Options
@onready var credits: Panel = $Credits
@onready var game_name: Label = $GameName
@onready var fondu_noir: ColorRect = $FonduLayer/FonduNoir

@onready var sign_start: Sprite2D = $MainButtons/SignStart
@onready var start_button: Button = $MainButtons/StartButton
var start_scale: Vector2
var sign_start_scale: Vector2

@onready var sign_setting: Sprite2D = $MainButtons/SignSettings
@onready var option_button: Button = $MainButtons/OptionButton
var setting_scale: Vector2
var sign_setting_scale: Vector2

@onready var sign_credits: Sprite2D = $MainButtons/SignCredits
@onready var credit_button: Button = $MainButtons/CreditsButton
var credits_scale: Vector2
var sign_credits_scale: Vector2

@onready var sign_quit: Sprite2D = $MainButtons/SignQuit
@onready var quit_button: Button = $MainButtons/QuitButton
var quit_scale: Vector2
var sign_quit_scale: Vector2

@onready var sign_back_setting: Sprite2D = $Options/SignBack
@onready var back_setting_button: Button = $Options/BackButton
var back_setting_scale: Vector2
var sign_back_setting_scale: Vector2

@onready var sign_back_credit: Sprite2D = $Credits/SignBack
@onready var back_credits_button: Button = $Credits/BackButton
var back_credits_scale: Vector2
var sign_back_credits_scale: Vector2

@onready var sign_change: Sprite2D = $Options/SignChange
@onready var change_button: Button = $Options/ChangeButton
var change_scale: Vector2
var sign_change_scale: Vector2

@onready var options_title: Label = $Options/OptionsTitle
@onready var click_sound: AudioStreamPlayer = $ClickSound

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	GlobalMusic.volume_db = -15.0
	
	# Définition de la taille de tous les boutons et de tous les panneaux
	start_scale = start_button.scale
	sign_start_scale = sign_start.scale
	setting_scale = option_button.scale
	sign_setting_scale = sign_setting.scale
	credits_scale = credit_button.scale
	sign_credits_scale = sign_credits.scale
	quit_scale = quit_button.scale
	sign_quit_scale = sign_quit.scale
	back_setting_scale = back_setting_button.scale
	sign_back_setting_scale = sign_back_setting.scale
	back_credits_scale = back_credits_button.scale
	sign_back_credits_scale = sign_back_credit.scale
	change_scale = change_button.scale
	sign_change_scale = sign_change.scale
	
	# On cache les dégradés sur les boutons
	start_button.material.set_shader_parameter("is_hovered", false)
	option_button.material.set_shader_parameter("is_hovered", false)
	credit_button.material.set_shader_parameter("is_hovered", false)
	quit_button.material.set_shader_parameter("is_hovered", false)
	back_setting_button.material.set_shader_parameter("is_hovered", false)
	back_credits_button.material.set_shader_parameter("is_hovered", false)
	
	# Mise en place de l'enlèvement du fondu
	fondu_noir.modulate.a = 1.0
	main_buttons.modulate.a = 1.0
	game_name.modulate.a = 1.0
	fondu_noir.visible = true
	main_buttons.visible = true
	game_name.visible = true
	options.visible = false
	credits.visible = false
	
	var t = create_tween()
	t.tween_property(fondu_noir, "modulate:a", 0.0, 0.6)
	await t.finished
	fondu_noir.visible = false
	
	var cursor = load("res://addons/assets/cursor.png")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(0, 0))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func transition(appear_list: Array[Control], disappear_list: Array[Control], back: bool) -> void:
	# Effectue une transition courante entre 2 pages du menu
	click_sound.play()
	if back:
		# On annule le spam d'appui de boutons
		for button in main_buttons.get_children():
			if button is Button: button.disabled = true
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
	if back:
		for panel in appear_list: 
			for button in panel.get_children():
				if button is Button : button.modulate = Color.BLACK
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
	
	if back:
		# On annule le spam d'appui de boutons
		for panel in appear_list:
			for button in panel.get_children():
				if button is Button : button.disabled = false
		# On remet la couleur initiale lorsque le curseur passe sur un bouton
			for button in panel.get_children():
				if button is Button : button.modulate = Color.WHITE

func _onStartButton_pressed() -> void:
	await transition([], [main_buttons, game_name], false)
	get_tree().change_scene_to_file("res://scenes/menus/tutoriel.tscn")

func _onOptionButton_pressed() -> void:
	transition([options], [main_buttons, game_name], false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onQuitButton_pressed() -> void:
	await transition([], [main_buttons, game_name], false)
	get_tree().quit()

func _onBackButton_pressed() -> void:
	transition([main_buttons, game_name], [options, credits], true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onCreditsButton_pressed() -> void:
	transition([credits], [main_buttons, game_name], false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onChangeButton_pressed() -> void:
	await transition([], [options], false)
	Global.launched_mode = 4
	get_tree().change_scene_to_file("res://scenes/game_scenes/scene_camera.tscn")

func _onStartButtonEnter() -> void:
	Global.ButtonEnter(start_button, start_scale, false, sign_start, sign_start_scale)

func _onStartButtonExit() -> void:
	Global.ButtonExit(start_button, start_scale, false, sign_start, sign_start_scale)

func _onOptionButtonEnter() -> void:
	Global.ButtonEnter(option_button, setting_scale, false, sign_setting, sign_setting_scale)

func _onOptionButtonExit() -> void:
	Global.ButtonExit(option_button, setting_scale, false, sign_setting, sign_setting_scale)

func _onCreditsButtonEnter() -> void:
	Global.ButtonEnter(credit_button, credits_scale, false, sign_credits, sign_credits_scale)

func _onCreditsButtonExit() -> void:
	Global.ButtonExit(credit_button, credits_scale, false, sign_credits, sign_credits_scale)

func _onQuitButtonEnter() -> void:
	Global.ButtonEnter(quit_button, quit_scale, false, sign_quit, sign_quit_scale)

func _onQuitButtonExit() -> void:
	Global.ButtonExit(quit_button, quit_scale, false, sign_quit, sign_quit_scale)

func _onBackButtonSettingEnter() -> void:
	Global.ButtonEnter(back_setting_button, back_setting_scale, false, sign_back_setting, sign_back_setting_scale)

func _onBackButtonSettingExit() -> void:
	Global.ButtonExit(back_setting_button, back_setting_scale, false, sign_back_setting, sign_back_setting_scale)

func _onBackButtonCreditEnter() -> void:
	Global.ButtonEnter(back_credits_button, back_credits_scale, false, sign_back_credit, sign_back_credits_scale)

func _onBackButtonCreditExit() -> void:
	Global.ButtonExit(back_credits_button, back_credits_scale, false, sign_back_credit, sign_back_credits_scale)

func _onChangeButtonEnter() -> void:
	Global.ButtonEnter(change_button, change_scale, false, sign_change, sign_change_scale)

func _onChangeButtonExit() -> void:
	Global.ButtonExit(change_button, change_scale, false, sign_change, sign_change_scale)
