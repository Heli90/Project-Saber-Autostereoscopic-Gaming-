extends Node3D

@onready var fondu_noir: ColorRect = $HUD/FonduLayer/FonduNoir
@onready var partie_timer: Timer = $PartieTimer
@onready var game_ending: ColorRect = $HUD/GameEnding
@onready var countdown_label: Label = $HUD/Countdown
@onready var cube_spawner: Node3D = $CubeSpawner
@onready var disappear_bloc_notif: Label = $DisappearBlocNotif

var global_score: int = 0
var pause_blocs : bool = false

func _ready() -> void:
	load_highest_score()
	print(ProjectSettings.globalize_path("user://"))
	game_ending.visible = false
	disappear_bloc_notif.visible = false
	var transition = create_tween()
	transition.tween_property(fondu_noir, "modulate:a", 0.0, 0.6)
	await transition.finished
	fondu_noir.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cube_spawner.activation()
	partie_timer.start()

func _process(_delta: float) -> void:
	pass

func set_blur_intensity(value: float):
	game_ending.material.set_shader_parameter("lod", value)

func _onPartieTimerTimeout() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	global_score = cube_spawner.current_score
	game_ending.add_score(global_score)
	get_tree().paused = true
	
	if global_score > game_ending.highest_score:
		save_highest_score(global_score)
		game_ending.ending_best_score.text = "Nouveau record, bravo !"
		game_ending.ending_best_score.position = Vector2(500, 720)
	
	var transition = create_tween()
	transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	transition.parallel().tween_property(game_ending, "modulate:a", 1.0, 0.5)
	transition.parallel().tween_method(set_blur_intensity, 0.0, 2.0, 0.5)
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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("StopTime"):
		pause_blocs = not pause_blocs
		cube_spawner.start_spawn = not pause_blocs
		for bloc in cube_spawner.blocs:
			if is_instance_valid(bloc):
				bloc.set_physics_process(not pause_blocs)
