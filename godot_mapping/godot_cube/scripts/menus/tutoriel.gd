extends Control
@onready var fondu_noir: ColorRect = $FonduLayer/FonduNoir
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var tutoriel_music: AudioStreamPlayer = $TutorielMusic
@onready var nom_j1: LineEdit = $NameInput/NomJ1
@onready var nom_j2: LineEdit = $NameInput/NomJ2
@onready var heal_mode_button: TextureButton = $HealModeButton

@export var in_game: bool = false

const LEADERBOARD_PATH = "user://leaderboard.cfg"
var healing: bool = false

func _ready() -> void:
	if not in_game: tutoriel_music.play()
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
	if heal_mode_button.activated: healing = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var nom1 = nom_j1.text.strip_edges()
	var nom2 = nom_j2.text.strip_edges()
	
	# Noms par défaut
	if nom1 == "": nom1 = "Joueur 1"
	if nom2 == "": nom2 = "Joueur 2"
	
	var config = ConfigFile.new()
	config.load(LEADERBOARD_PATH)
	config.set_value("Joueurs", "Nom_J1", nom1)
	config.set_value("Joueurs", "Nom_J2", nom2)
	config.save(LEADERBOARD_PATH)
	
	click_sound.play()
	var t = create_tween()
	fondu_noir.visible = true
	t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	t.chain().tween_interval(0.3)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/game_scenes/scene_TV.tscn")

func _onHealModeButton_pressed() -> void:
	heal_mode_button.activated = !heal_mode_button.activated
	healing = heal_mode_button.activated
	heal_mode_button.texture_normal = heal_mode_button.full_heart if healing else heal_mode_button.empty_heart
