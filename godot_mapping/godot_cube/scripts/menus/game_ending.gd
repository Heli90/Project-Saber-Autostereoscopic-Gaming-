extends ColorRect

@onready var fondu_noir: ColorRect = $FonduNoir
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var ending_title: Label = $TextContent/EndingTitle
@onready var ending_message: Label = $TextContent/EndingMessage
@onready var best_player_message: Label = $TextContent/BestPlayerMessage
@onready var best_player_text: Label = $TextContent/BestPlayerText
@onready var leaderboard_label: Label = $Leaderboard/Label

@onready var back_to_menu_button: Button = $BackToMenuButton
@onready var sign_back: Sprite2D = $SignBack
var back_button_scale: Vector2
var sign_back_scale: Vector2

func _ready() -> void:
	fondu_noir.modulate.a = 0.0
	fondu_noir.visible = false
	
	back_button_scale = back_to_menu_button.scale
	sign_back_scale = sign_back.scale

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
	get_tree().change_scene_to_file("res://scenes/menus/main_menu_3d.tscn")

func _onBackButtonEnter() -> void:
	Global.ButtonEnter(back_to_menu_button, back_button_scale, false, sign_back, sign_back_scale)

func _onBackButtonExit() -> void:
	Global.ButtonExit(back_to_menu_button, back_button_scale)
