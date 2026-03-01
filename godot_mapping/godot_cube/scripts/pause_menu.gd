extends ColorRect
@onready var menu_buttons: Panel = $MenuButtons
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var options: Panel = $Options
@onready var fondu_noir: ColorRect = $FonduLayer/FonduNoir

var affichage: bool = false
var latence_pause: float = 0.0

func _ready() -> void:
	menu_buttons.modulate.a = 0.0
	options.modulate.a = 0.0
	menu_buttons.visible = false
	options.visible = false
	fondu_noir.visible = false

func _process(delta: float) -> void:
	latence_pause += delta

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Menu") and latence_pause > 0.5:
		latence_pause = 0.0
		toggle_pause()

func toggle_pause():
	if not affichage:
		affichage = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# On s'assure que tout est visible avant d'animer
		menu_buttons.visible = true
		
		var transition = create_tween()
		transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		transition.parallel().tween_property(menu_buttons, "modulate:a", 1.0, 0.1)
		await transition.finished
	else:
		_onContinueButton_pressed()

func _onContinueButton_pressed() -> void:
	affichage = false
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var transition = create_tween().set_parallel(true)
	transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	transition.tween_property(menu_buttons, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.chain().tween_interval(0.3)
	await transition.finished
	
	menu_buttons.visible = false
	get_tree().paused = false

func _onOptionButton_pressed() -> void:
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
	
	for button in menu_buttons.get_children(): # On annule le spam d'appui de boutonss
		button.disabled = false
	# On remet la couleur initiale lorsque le curseur passe sur un bouton
	for button in menu_buttons.get_children():
		button.modulate = Color.WHITE
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
