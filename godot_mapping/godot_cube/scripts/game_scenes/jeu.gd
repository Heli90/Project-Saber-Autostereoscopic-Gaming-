extends Node3D

@onready var fondu_noir: ColorRect = $HUD/FonduLayer/FonduNoir
@onready var partie_timer: Timer = $PartieTimer
@onready var game_ending: ColorRect = $HUD/GameEnding
@onready var countdown_label: Label = $HUD/Countdown

var global_score: int = 0

func _ready() -> void:
	load_highest_score()
	print(ProjectSettings.globalize_path("user://"))
	game_ending.visible = false
	var transition = create_tween()
	transition.tween_property(fondu_noir, "modulate:a", 0.0, 0.6)
	await transition.finished
	fondu_noir.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	await _lancer_countdown()
	partie_timer.start()

func _lancer_countdown() -> void:
	countdown_label.visible = true

	for i in range(5, 0, -1):
		countdown_label.text = str(i)
		# Petite animation de scale pour chaque chiffre
		countdown_label.scale = Vector2(1.5, 1.5)
		var tween = create_tween()
		tween.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.3)
		await get_tree().create_timer(1.0).timeout

	countdown_label.text = "GO !"
	var tween_go = create_tween()
	tween_go.tween_property(countdown_label, "modulate:a", 0.0, 0.5)
	await tween_go.finished
	countdown_label.visible = false
	countdown_label.modulate.a = 1.0

func _process(_delta: float) -> void:
	pass

func set_blur_intensity(value: float):
	game_ending.material.set_shader_parameter("lod", value)

func _onPartieTimerTimeout() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	game_ending.add_score(global_score)
	get_tree().paused = true
	
	if global_score > game_ending.highest_score:
		save_highest_score(global_score)
		game_ending.ending_best_score.text = "Nouveau record, bravo !"
		game_ending.ending_best_score.position = Vector2(500, 720)
	
	var transition = create_tween()
	transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	transition.parallel().tween_property(game_ending, "modulate:a", 1.0, 0.1)
	transition.parallel().tween_method(set_blur_intensity, 0.0, 2.0, 0.1)
	await transition.finished
	game_ending.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func save_highest_score(new_score: int) -> void:
	game_ending.highest_score = new_score
	var config = ConfigFile.new()
	config.set_value("Progression", "Meilleur Score", game_ending.highest_score)
	config.save(game_ending.SAVE_PATH)

func load_highest_score() -> void:
	var config = ConfigFile.new()
	var err = config.load(game_ending.SAVE_PATH)
	
	if err != OK: game_ending.highest_score = 0
	else: game_ending.highest_score = config.get_value("Progression", "Meilleur Score", 0)
