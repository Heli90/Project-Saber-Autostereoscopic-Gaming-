extends Control

@onready var main_buttons: Panel = $MainButtons
@onready var options: Panel = $Options
@onready var credits: Panel = $Credits
@onready var mode_buttons: Panel = $ModeButtons
@onready var game_name: Label = $GameName
@onready var reset_score_page: Panel = $ResetScorePage
@onready var validation_score_page: Panel = $ValidationScorePage

@onready var option_button: Button = $MainButtons/OptionButton
@onready var credit_button: Button = $MainButtons/OptionButton

@onready var fondu_noir: ColorRect = $FonduLayer/FonduNoir

@onready var options_title: Label = $Options/OptionsTitle
@onready var music_title: Label = $Options/MusicTitle
@onready var sfx_title: Label = $Options/SFXTitle

@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var main_menu_music: AudioStreamPlayer = $MainMenuMusic

var highest_score: int = 0
const SAVE_PATH = "user://save_score.cfg"

func _ready() -> void:
	get_tree().paused = false
	main_menu_music.play()
	
	fondu_noir.modulate.a = 1.0
	main_buttons.modulate.a = 1.0
	game_name.modulate.a = 1.0
	fondu_noir.visible = true
	main_buttons.visible = true
	game_name.visible = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	options.visible = false
	credits.visible = false
	mode_buttons.visible = false
	reset_score_page.visible = false
	validation_score_page.visible = false
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
			button.disabled = true
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
				button.modulate = Color.BLACK
	if appear_list == []:
		# Il y a un changement de scène, donc, on fait un fondu.
		t.set_parallel(false)
		t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
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
				button.disabled = false
		# On remet la couleur initiale lorsque le curseur passe sur un bouton
			for button in panel.get_children():
				button.modulate = Color.WHITE

func _onStartButton_pressed() -> void:
	transition([mode_buttons], [main_buttons, game_name], false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onOptionButton_pressed() -> void:
	transition([options], [main_buttons, game_name], false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onQuitButton_pressed() -> void:
	await transition([], [main_buttons, game_name], false)
	get_tree().quit()

func _onBackButton_pressed() -> void:
	transition([main_buttons, game_name], [options, credits, mode_buttons, validation_score_page], true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onCreditsButton_pressed() -> void:
	transition([credits], [main_buttons, game_name], false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onPCButton_pressed() -> void:
	await transition([], [mode_buttons], false)
	get_tree().change_scene_to_file("res://scenes/game_scenes/scene_pc.tscn")

func _onTVButton_pressed() -> void:
	await transition([], [mode_buttons], false)
	get_tree().change_scene_to_file("res://scenes/menus/tutoriel.tscn")

func _onResetScoreButton_pressed() -> void:
	transition([reset_score_page], [mode_buttons], false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onNoButton_pressed() -> void:
	transition([mode_buttons], [reset_score_page], true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onYesButton_pressed() -> void:
	transition([validation_score_page], [reset_score_page], false)
	reset_highest_score()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func reset_highest_score() -> void:
	var config = ConfigFile.new()
	config.set_value("Progression", "Meilleur Score", 0)
	config.save(SAVE_PATH)
