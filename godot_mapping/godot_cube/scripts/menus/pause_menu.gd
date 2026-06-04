extends ColorRect
@onready var menu_buttons: Panel = $MenuButtons
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var options: Panel = $Options
@onready var fondu_noir: ColorRect = $FonduNoir
@onready var pause_menu: ColorRect = $"."
@onready var camera_button: Button = $MenuButtons/CameraButton
@onready var landmarks_proceed = $"../../LandMarksProceed"
@onready var select_camera: ConfirmationDialog = $"../../LandMarksProceed/SelectCamera"

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
	var appui_synchro: bool = event.is_action_pressed("Menu") and latence_pause > 0.75 and (not on_option_menu)
	if appui_synchro and Global.launched_mode > 0:
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
	get_tree().change_scene_to_file("res://scenes/menus/main_menu_3d.tscn")

func _onCameraButton_pressed() -> void :
	landmarks_proceed.reload_camera_selection()
