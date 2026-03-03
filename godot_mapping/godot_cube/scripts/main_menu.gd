extends Control

@onready var main_buttons: Panel = $MainButtons
@onready var options: Panel = $Options
@onready var credits: Panel = $Credits
@onready var mode_buttons: Panel = $ModeButtons
@onready var game_name: Label = $GameName

@onready var option_button: Button = $MainButtons/OptionButton
@onready var credit_button: Button = $MainButtons/OptionButton

@onready var fondu_noir: ColorRect = $FonduLayer/FonduNoir

@onready var options_title: Label = $Options/OptionsTitle
@onready var music_title: Label = $Options/MusicTitle
@onready var sfx_title: Label = $Options/SFXTitle

@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var main_menu_music: AudioStreamPlayer = $MainMenuMusic

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Menu"):
		pass

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
	var transition = create_tween()
	transition.tween_property(fondu_noir, "modulate:a", 0.0, 0.6)
	await transition.finished
	fondu_noir.visible = false
	
	var cursor = load("res://addons/assets/cursor.png")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(0, 0))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_StartButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var transition = create_tween().set_parallel(true)
	transition.tween_property(main_buttons, "modulate:a", 0.0, 0.1)
	transition.tween_property(game_name, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		options.modulate.a = 0.0
		main_buttons.visible = false
		game_name.visible = false
		mode_buttons.visible = true)
	transition.tween_property(mode_buttons, "modulate:a", 1.0, 0.1)
	await transition.finished
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_OptionButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var transition = create_tween().set_parallel(true)
	transition.tween_property(main_buttons, "modulate:a", 0.0, 0.1)
	transition.tween_property(game_name, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		options.modulate.a = 0.0
		main_buttons.visible = false
		game_name.visible = false
		options.visible = true)
	transition.tween_property(options, "modulate:a", 1.0, 0.1)
	await transition.finished
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_QuitButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var transition = create_tween().set_parallel(true)
	transition.tween_property(main_buttons, "modulate:a", 0.0, 0.1)
	transition.tween_property(game_name, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		fondu_noir.modulate.a = 0.0
		fondu_noir.visible = true)
	transition.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	transition.chain().tween_interval(0.3)
	await transition.finished
	get_tree().quit()

func _on_BackButton_pressed() -> void:
	click_sound.play()
	for button in main_buttons.get_children(): # On annule le spam d'appui de boutonss
		button.disabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var transition = create_tween().set_parallel(true)
	transition.tween_property(options, "modulate:a", 0.0, 0.1)
	transition.tween_property(credits, "modulate:a", 0.0, 0.1)
	transition.tween_property(mode_buttons, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		main_buttons.visible = true
		game_name.visible = true
		options.visible = false
		credits.visible = false
		mode_buttons.visible = false)
	transition.set_parallel(true)
	
	# On remet tous les textes en noir pour éviter un flash à l'écran
	for button in main_buttons.get_children():
		button.modulate = Color.BLACK
	
	transition.tween_property(main_buttons, "modulate:a", 1.0, 0.1)
	transition.tween_property(game_name, "modulate:a", 1.0, 0.1)
	transition.chain()
	await transition.finished
	
	for button in main_buttons.get_children(): # On annule le spam d'appui de boutonss
		button.disabled = false
	# On remet la couleur initiale lorsque le curseur passe sur un bouton
	for button in main_buttons.get_children():
		button.modulate = Color.WHITE
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_CreditsButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var transition = create_tween().set_parallel(true)
	transition.tween_property(main_buttons, "modulate:a", 0.0, 0.1)
	transition.tween_property(game_name, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		credits.modulate.a = 0.0
		main_buttons.visible = false
		game_name.visible = false
		credits.visible = true)
	transition.tween_property(credits, "modulate:a", 1.0, 0.1)
	await transition.finished

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onModeButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var transition = create_tween().set_parallel(true)
	transition.tween_property(mode_buttons, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		fondu_noir.modulate.a = 0.0
		fondu_noir.visible = true)
	transition.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	transition.chain().tween_interval(0.3)
	await transition.finished

func _onPCButton_pressed() -> void:
	await _onModeButton_pressed()
	get_tree().change_scene_to_file("res://scenes/cube.tscn")

func _onTVButton_pressed() -> void:
	await _onModeButton_pressed()
	get_tree().change_scene_to_file("res://scenes/generation_image3D.tscn")
