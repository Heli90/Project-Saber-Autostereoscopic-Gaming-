extends ColorRect

var score: int = 0
@onready var fondu_noir: ColorRect = $FonduNoir
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var back_to_menu_button: Button = $BackToMenuButton
@onready var ending_title: Label = $TextContent/EndingTitle
@onready var ending_message: Label = $TextContent/EndingMessage
@onready var ending_score: Label = $TextContent/EndingScore
@onready var ending_best_score: Label = $TextContent/EndingBestScore

var highest_score: int = 0
const SAVE_PATH = "user://save_score.cfg"

func _ready() -> void:
	fondu_noir.modulate.a = 0.0
	fondu_noir.visible = false
	update_score_display()

func add_score(amount: int):
	score += amount
	update_score_display()

func update_score_display():
	# On modifie uniquement la valeur du score
	ending_score.text[-1] = str(score) 
	ending_best_score.text[-1] = str(highest_score)

func _onBackToMenuButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var transition = create_tween().set_parallel(true)
	transition.tween_property(back_to_menu_button, "modulate:a", 0.0, 0.1)
	transition.tween_property(ending_title, "modulate:a", 0.0, 0.1)
	transition.tween_property(ending_message, "modulate:a", 0.0, 0.1)
	transition.tween_property(ending_score, "modulate:a", 0.0, 0.1)
	transition.tween_property(ending_best_score, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.tween_callback(func():
		fondu_noir.modulate.a = 0.0
		fondu_noir.visible = true)
	transition.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	transition.chain().tween_interval(0.3)
	await transition.finished
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")

func load_highest_score() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err != OK: highest_score = 0
	else: highest_score = config.get_value("Progression", "Meilleur Score", 0)
