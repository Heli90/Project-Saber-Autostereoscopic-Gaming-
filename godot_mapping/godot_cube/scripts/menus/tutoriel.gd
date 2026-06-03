extends Control
@onready var fondu_noir: ColorRect = $FonduLayer/FonduNoir
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var heal_sound: AudioStreamPlayer = $HealSound
@onready var tutoriel_music: AudioStreamPlayer = $TutorielMusic
@onready var nom_j1: LineEdit = $NameInput/NomJ1
@onready var nom_j2: LineEdit = $NameInput/NomJ2

@onready var select_level: Control = $SelectLevel

@onready var tuto_level_sign: Sprite2D = $SelectLevel/Titles/TutoLevelSign
@onready var tuto_level: Label = $SelectLevel/Titles/TutoLevel
@onready var game_level_sign: Sprite2D = $SelectLevel/Titles/GameLevelSign
@onready var game_level: Label = $SelectLevel/Titles/GameLevel
@onready var cassette_tuto: TextureButton = $SelectLevel/Cassettes/CassetteTuto
@onready var cassette_game: TextureButton = $SelectLevel/Cassettes/CassetteGame
@onready var cassette_sound: AudioStreamPlayer2D = $SelectLevel/CassetteSound

@onready var sign_start: Sprite2D = $Start/SignStart
@onready var start_button: Button = $Start/StartButton
var start_scale: Vector2
var sign_start_scale: Vector2

@onready var sign_back: Sprite2D = $SelectLevel/Menu/SignBack
@onready var back_button: Button = $SelectLevel/Menu/BackButton
var back_scale: Vector2
var sign_back_scale: Vector2

@onready var sign_menu: Sprite2D = $Menu/SignMenu
@onready var menu_button: Button = $Menu/MenuButton
var menu_scale: Vector2
var sign_menu_scale: Vector2

@onready var heal_mode_button: TextureButton = $Modes/HealModeButton
var heal_scale: Vector2
var heal_sound_transition: bool

const LEADERBOARD_PATH: String = "user://leaderboard.cfg"
const BUTTON_SCALE_FACTOR: float = 1.025
const HEART_SCALE_FACTOR: float = 1.075
const SCALE_DURATION: float = 0.2

var first_scale_transition: Tween
var loop_scale_transition_button: Tween
var loop_scale_transition_sign: Tween

func _ready() -> void:
	game_level_sign.modulate.a = 0.0
	game_level.modulate.a = 0.0
	cassette_game.modulate.a = 0.0
	
	menu_scale = menu_button.scale
	sign_menu_scale = sign_menu.scale
	start_scale = start_button.scale
	sign_start_scale = sign_start.scale
	back_scale = back_button.scale
	sign_back_scale = sign_back.scale
	heal_scale = heal_mode_button.scale
	
	tutoriel_music.volume_db = -15.0
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

func _process(_delta: float) -> void:
	if heal_sound.is_playing(): heal_sound_transition = true
	else: heal_sound_transition = false

func _onStartButton_pressed() -> void:
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
	# Apparition du fondu
	var t1 = create_tween()
	fondu_noir.visible = true
	t1.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	t1.chain().tween_interval(0.3)
	await t1.finished
	
	# On change de page de sélection
	select_level.visible = true

	var t2 = create_tween()
	t2.tween_property(fondu_noir, "modulate:a", 0.0, 0.5)
	t2.chain().tween_interval(0.3)
	await t2.finished
	fondu_noir.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onHealModeButton_pressed() -> void:
	if heal_sound_transition: pass
	else:
		heal_sound.play()
		heal_mode_button.activated = !heal_mode_button.activated
		Global.healing = heal_mode_button.activated
		heal_mode_button.texture_normal = heal_mode_button.full_heart if heal_mode_button.activated else heal_mode_button.empty_heart

func _onTutoCassette_pressed() -> void:
	cassette_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var t = create_tween().set_parallel(true)
	fondu_noir.visible = true
	t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	t.chain().tween_property(tutoriel_music, "volume_db", -80.0, 0.5)
	t.chain().tween_interval(0.3)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/game_scenes/scene_TV.tscn")

func _onCassetteGame_pressed() -> void:
	cassette_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var t = create_tween().set_parallel(true)
	fondu_noir.visible = true
	t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	t.chain().tween_property(tutoriel_music, "volume_db", -80.0, 0.5)
	t.chain().tween_interval(0.3)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/game_scenes/scene_TV.tscn")

func _onMenuButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var t = create_tween().set_parallel(true)
	fondu_noir.visible = true
	t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	t.chain().tween_property(tutoriel_music, "volume_db", -80.0, 0.5)
	t.chain().tween_interval(0.3)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/menus/main_menu_3d.tscn")

func _onBackButton_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	click_sound.play()
	# Apparition du fondu
	var t1 = create_tween()
	fondu_noir.visible = true
	t1.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	t1.chain().tween_interval(0.3)
	await t1.finished
	
	# On revient à la page d'inscription
	select_level.visible = false

	var t2 = create_tween()
	t2.tween_property(fondu_noir, "modulate:a", 0.0, 0.5)
	t2.chain().tween_interval(0.3)
	await t2.finished
	fondu_noir.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _onLeftArrows_pressed() -> void: onArrows_pressed(0)
func _onRightArrows_pressed() -> void: onArrows_pressed(1)

func onArrows_pressed(direction: int) -> void:
	var t_in : Tween
	var t_out = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT)
	if direction == 0:
		if tuto_level.visible:
			# Appui sur la flèche de gauche avec la cassette de tutoriel affichée
			t_out.tween_property(cassette_tuto, "position", Vector2(303, 280), 0.2)
			t_out.tween_property(tuto_level_sign, "position", Vector2(897, 199), 0.2)
			t_out.tween_property(tuto_level, "position", Vector2(753, 167), 0.2)

			t_out.tween_property(cassette_game, "position", Vector2(787, 369), 0.2)
			t_out.tween_property(game_level_sign, "position", Vector2(995, 199), 0.2)
			t_out.tween_property(game_level, "position", Vector2(705, 167), 0.2)

			t_out.tween_property(cassette_tuto, "modulate:a", 0.0, 0.2)
			t_out.tween_property(tuto_level_sign, "modulate:a", 0.0, 0.2)
			t_out.tween_property(tuto_level, "modulate:a", 0.0, 0.2)
			await t_out.finished

			cassette_tuto.visible = false
			tuto_level_sign.visible = false
			tuto_level.visible = false
			cassette_game.visible = true
			game_level_sign.visible = true
			game_level.visible = true
			
			t_in = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT)
			t_in.tween_property(cassette_game, "position", Vector2(606, 369), 0.2)
			t_in.tween_property(game_level_sign, "position", Vector2(940, 199), 0.2)
			t_in.tween_property(game_level, "position", Vector2(650, 167), 0.2)

			t_in.tween_property(cassette_game, "modulate:a", 1.0, 0.2)
			t_in.tween_property(game_level_sign, "modulate:a", 1.0, 0.2)
			t_in.tween_property(game_level, "modulate:a", 1.0, 0.2)
			await t_in.finished
		else:
			# Appui sur la flèche de gauche avec la cassette de jeu affichée
			t_out.tween_property(cassette_game, "position", Vector2(425, 369), 0.2)
			t_out.tween_property(game_level_sign, "position", Vector2(885, 199), 0.2)
			t_out.tween_property(game_level, "position", Vector2(595, 167), 0.2)

			t_out.tween_property(cassette_tuto, "position", Vector2(657, 280), 0.2)
			t_out.tween_property(tuto_level_sign, "position", Vector2(1007, 199), 0.2)
			t_out.tween_property(tuto_level, "position", Vector2(863, 167), 0.2)

			t_out.tween_property(cassette_game, "modulate:a", 0.0, 0.2)
			t_out.tween_property(game_level_sign, "modulate:a", 0.0, 0.2)
			t_out.tween_property(game_level, "modulate:a", 0.0, 0.2)
			await t_out.finished

			cassette_game.visible = false
			game_level_sign.visible = false
			game_level.visible = false
			cassette_tuto.visible = true
			tuto_level_sign.visible = true
			tuto_level.visible = true
			
			t_in = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT)
			t_in.tween_property(cassette_tuto, "position", Vector2(480, 280), 0.2)
			t_in.tween_property(tuto_level_sign, "position", Vector2(952, 199), 0.2)
			t_in.tween_property(tuto_level, "position", Vector2(808, 167), 0.2)

			t_in.tween_property(cassette_tuto, "modulate:a", 1.0, 0.2)
			t_in.tween_property(tuto_level_sign, "modulate:a", 1.0, 0.2)
			t_in.tween_property(tuto_level, "modulate:a", 1.0, 0.2)
			await t_in.finished
	else:
		if tuto_level.visible:
			# Appui sur la flèche de droite avec la cassette de tutoriel affichée
			t_out.tween_property(cassette_tuto, "position", Vector2(657, 280), 0.2)
			t_out.tween_property(tuto_level_sign, "position", Vector2(1007, 199), 0.2)
			t_out.tween_property(tuto_level, "position", Vector2(863, 167), 0.2)

			t_out.tween_property(cassette_game, "position", Vector2(425, 369), 0.2)
			t_out.tween_property(game_level_sign, "position", Vector2(885, 199), 0.2)
			t_out.tween_property(game_level, "position", Vector2(595, 167), 0.2)

			t_out.tween_property(cassette_tuto, "modulate:a", 0.0, 0.2)
			t_out.tween_property(tuto_level_sign, "modulate:a", 0.0, 0.2)
			t_out.tween_property(tuto_level, "modulate:a", 0.0, 0.2)
			await t_out.finished

			cassette_tuto.visible = false
			tuto_level_sign.visible = false
			tuto_level.visible = false
			cassette_game.visible = true
			game_level_sign.visible = true
			game_level.visible = true
			
			t_in = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT)
			t_in.tween_property(cassette_game, "position", Vector2(606, 369), 0.2)
			t_in.tween_property(game_level_sign, "position", Vector2(940, 199), 0.2)
			t_in.tween_property(game_level, "position", Vector2(650, 167), 0.2)

			t_in.tween_property(cassette_game, "modulate:a", 1.0, 0.2)
			t_in.tween_property(game_level_sign, "modulate:a", 1.0, 0.2)
			t_in.tween_property(game_level, "modulate:a", 1.0, 0.2)
			await t_in.finished
		else:
			# Appui sur la flèche de gauche avec la cassette de jeu affichée
			t_out.tween_property(cassette_game, "position", Vector2(787, 369), 0.2)
			t_out.tween_property(game_level_sign, "position", Vector2(995, 199), 0.2)
			t_out.tween_property(game_level, "position", Vector2(705, 167), 0.2)

			t_out.tween_property(cassette_tuto, "position", Vector2(303, 280), 0.2)
			t_out.tween_property(tuto_level_sign, "position", Vector2(897, 199), 0.2)
			t_out.tween_property(tuto_level, "position", Vector2(753, 167), 0.2)

			t_out.tween_property(cassette_game, "modulate:a", 0.0, 0.2)
			t_out.tween_property(game_level_sign, "modulate:a", 0.0, 0.2)
			t_out.tween_property(game_level, "modulate:a", 0.0, 0.2)
			await t_out.finished

			cassette_game.visible = false
			game_level_sign.visible = false
			game_level.visible = false
			cassette_tuto.visible = true
			tuto_level_sign.visible = true
			tuto_level.visible = true
			
			t_in = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT)
			t_in.tween_property(cassette_tuto, "position", Vector2(480, 280), 0.2)
			t_in.tween_property(tuto_level_sign, "position", Vector2(952, 199), 0.2)
			t_in.tween_property(tuto_level, "position", Vector2(808, 167), 0.2)

			t_in.tween_property(cassette_tuto, "modulate:a", 1.0, 0.2)
			t_in.tween_property(tuto_level_sign, "modulate:a", 1.0, 0.2)
			t_in.tween_property(tuto_level, "modulate:a", 1.0, 0.2)
			await t_in.finished

func ButtonEnter(button, button_scale: Vector2, life = false, sign_sprite: Sprite2D = null,  sign_scale: Vector2 = Vector2(0, 0)) -> void:
	if first_scale_transition: first_scale_transition.kill()
	if loop_scale_transition_button: loop_scale_transition_button.kill()
	if loop_scale_transition_sign: loop_scale_transition_sign.kill()

	first_scale_transition = create_tween().set_parallel(true)
	first_scale_transition.set_ease(Tween.EASE_OUT)
	first_scale_transition.set_trans(Tween.TRANS_BACK)
	if life: first_scale_transition.tween_property(button, "scale", button_scale * HEART_SCALE_FACTOR, SCALE_DURATION)
	else: first_scale_transition.tween_property(button, "scale", button_scale * BUTTON_SCALE_FACTOR, SCALE_DURATION)
	if sign_sprite: first_scale_transition.tween_property(sign_sprite, "scale", sign_scale * (BUTTON_SCALE_FACTOR), SCALE_DURATION)
	await first_scale_transition.finished
	
	loop_scale_transition_button = create_tween().set_loops()
	loop_scale_transition_button.set_ease(Tween.EASE_OUT)
	loop_scale_transition_button.set_trans(Tween.TRANS_BACK)
	if life:
		loop_scale_transition_button.tween_property(button, "scale", button_scale / (HEART_SCALE_FACTOR ** 2), SCALE_DURATION / 2)
		loop_scale_transition_button.tween_property(button, "scale", button_scale * (HEART_SCALE_FACTOR ** 2), SCALE_DURATION * 2)
	else:
		loop_scale_transition_button.tween_property(button, "scale", button_scale / (BUTTON_SCALE_FACTOR ** 2), SCALE_DURATION / 2)
		loop_scale_transition_button.tween_property(button, "scale", button_scale * (BUTTON_SCALE_FACTOR ** 2), SCALE_DURATION * 2)
	if sign_sprite:
		loop_scale_transition_sign = create_tween().set_loops()
		loop_scale_transition_sign.set_ease(Tween.EASE_OUT)
		loop_scale_transition_sign.set_trans(Tween.TRANS_BACK)
		loop_scale_transition_sign.tween_property(sign_sprite, "scale", sign_scale / (BUTTON_SCALE_FACTOR ** 2), SCALE_DURATION / 2)
		loop_scale_transition_sign.tween_property(sign_sprite, "scale", sign_scale * (BUTTON_SCALE_FACTOR ** 2), SCALE_DURATION * 2)

func ButtonExit(button, button_scale: Vector2, life = false, sign_sprite: Sprite2D = null, sign_scale: Vector2 = Vector2(0, 0)) -> void:
	if first_scale_transition: first_scale_transition.kill()
	if loop_scale_transition_button: loop_scale_transition_button.kill()
	if loop_scale_transition_sign: loop_scale_transition_sign.kill()

	var out = create_tween()
	out.set_ease(Tween.EASE_OUT)
	out.set_trans(Tween.TRANS_SINE)
	out.set_parallel(true)
	out.tween_property(button, "scale", button_scale, SCALE_DURATION)
	if sign_sprite: out.tween_property(sign_sprite, "scale", sign_scale, SCALE_DURATION)

func _onMenuButtonEnter() -> void:
	ButtonEnter(menu_button, menu_scale, false, sign_menu, sign_menu_scale)

func _onMenuButtonExit() -> void:
	ButtonExit(menu_button, menu_scale, false, sign_menu, sign_menu_scale)

func _onStartButtonEnter() -> void:
	ButtonEnter(start_button, start_scale, false, sign_start, sign_start_scale)

func _onStartButtonExit() -> void:
	ButtonExit(start_button, start_scale, false, sign_start, sign_start_scale)

func _onBackButtonEnter() -> void:
	ButtonEnter(back_button, back_scale, false, sign_back, sign_back_scale)

func _onBackButtonExit() -> void:
	ButtonExit(back_button, back_scale, false, sign_back, sign_back_scale)

func _onHealMouseEnter() -> void:
	ButtonEnter(heal_mode_button, heal_scale, true)

func _onHealMouseExit() -> void:
	ButtonExit(heal_mode_button, heal_scale, true)
