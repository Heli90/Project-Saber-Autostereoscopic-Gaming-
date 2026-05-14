extends Control
@onready var fondu_noir: ColorRect = $FonduLayer/FonduNoir
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var tutoriel_music: AudioStreamPlayer = $TutorielMusic

func _ready() -> void:
	tutoriel_music.play()
	fondu_noir.modulate.a = 1.0
	fondu_noir.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var t = create_tween()
	t.tween_property(fondu_noir, "modulate:a", 0.0, 0.6)
	await t.finished
	fondu_noir.visible = false
	
	var cursor = load("res://addons/assets/cursor.png")
	Input.set_custom_mouse_cursor(cursor, Input.CURSOR_ARROW, Vector2(0, 0))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onStartButton_pressed() -> void:
	click_sound.play()
	
	var t = create_tween()
	fondu_noir.visible = true
	t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	t.chain().tween_interval(0.3)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/game_scenes/scene_TV.tscn")
