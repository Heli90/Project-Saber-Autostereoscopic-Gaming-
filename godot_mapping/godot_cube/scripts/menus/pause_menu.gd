extends ColorRect
@onready var menu_buttons: Panel = $MenuButtons
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var options: Panel = $Options
@onready var fondu_noir: ColorRect = $FonduNoir
@onready var pause_menu: ColorRect = $"."
@onready var test_button: Button = $MenuButtons/TestButton
var j1_PC: CharacterBody3D
var j2_PC: CharacterBody3D
var j1_TV: CharacterBody3D
var j2_TV: CharacterBody3D

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
	pause_menu.material.set_shader_parameter("lod", 0.0)

func _process(delta: float) -> void:
	latence_pause += delta

func _input(event: InputEvent) -> void:
	# On vérifie l'appui de Echap ainsi que le respect du temps de latence et d'animation
	if event.is_action_pressed("Menu") and latence_pause > 0.75 and (not on_option_menu):
		latence_pause = 0.0
		get_viewport().set_input_as_handled()
		toggle_pause()

func set_blur_intensity(value: float):
	pause_menu.material.set_shader_parameter("lod", value)

func toggle_pause():
	if (not affichage):
		affichage = true
		get_tree().paused = true
		# On s'assure que tout est visible avant d'animer
		menu_buttons.visible = true
		
		var transition = create_tween()
		transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		transition.parallel().tween_property(menu_buttons, "modulate:a", 1.0, 0.1)
		transition.parallel().tween_method(set_blur_intensity, 0.0, 2.0, 0.1)
		await transition.finished
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		_onContinueButton_pressed()

func _onContinueButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var transition = create_tween().set_parallel(true)
	transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	transition.tween_property(menu_buttons, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.3)
	transition.parallel().tween_method(set_blur_intensity, 2.0, 0.0, 0.1)
	await transition.finished
	
	latence_pause = 0.0
	menu_buttons.visible = false
	on_option_menu = false
	affichage = false
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
		button.disabled = true
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
		button.modulate = Color.BLACK
	
	transition.tween_property(menu_buttons, "modulate:a", 1.0, 0.1)
	transition.chain()
	await transition.finished
	
	for button in menu_buttons.get_children(): # On annule le spam d'appui de boutons
		button.disabled = false
	# On remet la couleur initiale lorsque le curseur passe sur un bouton
	for button in menu_buttons.get_children():
		button.modulate = Color.WHITE
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
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func _onTestButton_pressed() -> void:
	# On charge les joueurs selon la scène
	j1_PC = get_node_or_null("../../../SplitScreens/Camera1/POV1/J1")
	j2_PC = get_node_or_null("../../../SplitScreens/Camera2/POV2/J2")
	j1_TV = get_node_or_null("../../../J1")
	j2_TV = get_node_or_null("../../../J2")

	# Téléportation en zone de test
	if test_button.text == "Zone Test":
		test_button.text = "Zone Jeu"
		if j1_PC and j2_PC:
			j1_PC.position = Vector3(-4.0, 0.75, 4.0)
			j2_PC.position = Vector3(4.0, 0.75, 4.0)
		else:
			j1_TV.position = Vector3(-4.0, 0.75, 4.0)
			j2_TV.position = Vector3(4.0, 0.75, 4.0)
	# Téléportation hors de la zone de test
	else:
		test_button.text = "Zone Test"
		if j1_PC and j2_PC:
			j1_PC.position = Vector3(-10.0, 1.75, 35.0)
			j2_PC.position = Vector3(10.0, 1.75, 35.0)
		else:
			j1_TV.position = Vector3(-10.0, 1.75, 35.0)
			j2_TV.position = Vector3(10.0, 1.75, 35.0)
	_onContinueButton_pressed()
