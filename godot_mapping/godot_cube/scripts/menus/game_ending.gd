extends ColorRect

var score: int = 0
@onready var fondu_noir: ColorRect = $FonduNoir
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var back_to_menu_button: Button = $BackToMenuButton
@onready var ending_title: Label = $TextContent/EndingTitle
@onready var ending_message: Label = $TextContent/EndingMessage
@onready var best_player_message: Label = $TextContent/BestPlayerMessage
@onready var best_player_text: Label = $TextContent/BestPlayerText
@onready var leaderboard_label: Label = $Leaderboard/Label

func _ready() -> void:
	fondu_noir.modulate.a = 0.0
	fondu_noir.visible = false

func _onBackToMenuButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var transition = create_tween().set_parallel(true)
	transition.tween_property(back_to_menu_button, "modulate:a", 0.0, 0.1)
	transition.tween_property(ending_title, "modulate:a", 0.0, 0.1)
	transition.tween_property(ending_message, "modulate:a", 0.0, 0.1)
	transition.tween_property(best_player_message, "modulate:a", 0.0, 0.1)
	transition.tween_property(best_player_text, "modulate:a", 0.0, 0.1)
	transition.tween_property(leaderboard_label, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.tween_callback(func():
		fondu_noir.modulate.a = 0.0
		fondu_noir.visible = true)
	transition.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	transition.chain().tween_interval(0.3)
	await transition.finished
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
