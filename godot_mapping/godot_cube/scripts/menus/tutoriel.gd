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
@onready var effect_level_sign: Sprite2D = $SelectLevel/Titles/EffectLevelSign
@onready var effect_level: Label = $SelectLevel/Titles/EffectLevel
@onready var cassette_tuto: TextureButton = $SelectLevel/Cassettes/CassetteTuto
@onready var cassette_game: TextureButton = $SelectLevel/Cassettes/CassetteGame
@onready var cassette_effect: TextureButton = $SelectLevel/Cassettes/CassetteEffect
@onready var cassette_sound: AudioStreamPlayer2D = $SelectLevel/CassetteSound
var array_sign: Array[Sprite2D]
var array_cassette: Array[TextureButton]
var array_label: Array[Label]

# Tutoriel : 0 / Jeu : 1 / Foire aux effets : 2
var printed_cassette: int = 0

# Flèches servant à changer de cassette
@onready var left_arrows: TextureButton = $SelectLevel/LeftArrows
@onready var right_arrows: TextureButton = $SelectLevel/RightArrows

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

@onready var easter_egg_plane: Sprite2D = $EasterEgg/EasterEggPlane
var vitesse_deplacement: float = 50.0

const LEADERBOARD_PATH: String = "user://leaderboard.cfg"

func _ready() -> void:
	# Initialisation de tous les tableaux
	array_sign = [tuto_level_sign, game_level_sign, effect_level_sign]
	array_cassette = [cassette_tuto, cassette_game, cassette_effect]
	array_label = [tuto_level, game_level, effect_level]
	
	for i in range(1, len(array_sign)):
		array_cassette[i].modulate.a = 0.0
		array_sign[i].modulate.a = 0.0
		array_label[i].modulate.a = 0.0
	
	# Définition de la taille de tous les boutons et de tous les panneaux
	menu_scale = menu_button.scale
	sign_menu_scale = sign_menu.scale
	start_scale = start_button.scale
	sign_start_scale = sign_start.scale
	back_scale = back_button.scale
	sign_back_scale = sign_back.scale
	heal_scale = heal_mode_button.scale
	
	# On cache les degradés de tous les boutons
	start_button.material.set_shader_parameter("is_hovered", false)
	back_button.material.set_shader_parameter("is_hovered", false)
	menu_button.material.set_shader_parameter("is_hovered", false)
	
	
	# Mise en place de l'enlèvement du fondu
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

func _process(delta: float) -> void:
	if heal_sound.is_playing(): heal_sound_transition = true
	else: heal_sound_transition = false
	
	if not select_level.visible: easter_egg_plane.visible = true
	else: easter_egg_plane.visible = false

	if easter_egg_plane.position.x < -235.0: easter_egg_plane.position.x = 2145.0
	else: easter_egg_plane.position.x -= vitesse_deplacement * delta

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
	Global.launched_mode = 1
	get_tree().change_scene_to_file("res://scenes/game_scenes/tutoriel_3d.tscn")

func _onCassetteGame_pressed() -> void:
	cassette_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var t = create_tween().set_parallel(true)
	fondu_noir.visible = true
	t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	t.chain().tween_property(tutoriel_music, "volume_db", -80.0, 0.5)
	t.chain().tween_interval(0.3)
	await t.finished
	Global.launched_mode = 2
	get_tree().change_scene_to_file("res://scenes/game_scenes/scene_TV.tscn")

func _onCassetteEffect_pressed() -> void:
	cassette_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var t = create_tween().set_parallel(true)
	fondu_noir.visible = true
	t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	t.chain().tween_property(tutoriel_music, "volume_db", -80.0, 0.5)
	t.chain().tween_interval(0.3)
	await t.finished
	Global.launched_mode = 3
	get_tree().change_scene_to_file("res://scenes/game_scenes/scene_effects.tscn")

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

func _onLeftArrows_pressed() -> void:
	left_arrows.disabled = true
	onArrows_pressed(0)
	await get_tree().create_timer(0.25).timeout
	left_arrows.disabled = false

func _onRightArrows_pressed() -> void:
	right_arrows.disabled = true
	onArrows_pressed(1)
	await get_tree().create_timer(0.25).timeout
	right_arrows.disabled = false

func get_new_pos(node: Node, pos: Vector2) -> Vector2:
	return node.position + pos

func move_cassette_to_left(i: int) -> void:
	var t_out: Tween = create_tween().set_parallel(true)
	var j: int = (i-1)%3
	# Disparition de l'ancienne cassette
	t_out.tween_property(array_cassette[i], "position", get_new_pos(array_cassette[i], Vector2(100, 0)), 0.2)
	t_out.tween_property(array_sign[i], "position", get_new_pos(array_sign[i], Vector2(100, 0)), 0.2)
	t_out.tween_property(array_label[i], "position", get_new_pos(array_label[i], Vector2(100, 0)), 0.2)
	t_out.tween_property(array_cassette[j], "position", get_new_pos(array_cassette[j], Vector2(-100, 0)), 0.2)
	t_out.tween_property(array_sign[j], "position", get_new_pos(array_sign[j], Vector2(-100, 0)), 0.2)
	t_out.tween_property(array_label[j], "position", get_new_pos(array_label[j], Vector2(-100, 0)), 0.2)
	t_out.tween_property(array_cassette[i], "modulate:a", 0.0, 0.2)
	t_out.tween_property(array_sign[i], "modulate:a", 0.0, 0.2)
	t_out.tween_property(array_label[i], "modulate:a", 0.0, 0.2)
	await t_out.finished
	
	array_cassette[i].visible = false
	array_sign[i].visible = false
	array_label[i].visible = false
	array_cassette[j].visible = true
	array_sign[j].visible = true
	array_label[j].visible = true
	
	# Apparition de la nouvelle cassette
	var t_in: Tween = create_tween().set_parallel(true)
	t_in.tween_property(array_cassette[i], "position", get_new_pos(array_cassette[i], Vector2(-100, 0)), 0.2)
	t_in.tween_property(array_sign[i], "position", get_new_pos(array_sign[i], Vector2(-100, 0)), 0.2)
	t_in.tween_property(array_label[i], "position", get_new_pos(array_label[i], Vector2(-100, 0)), 0.2)
	t_in.tween_property(array_cassette[j], "position", get_new_pos(array_cassette[j], Vector2(100, 0)), 0.2)
	t_in.tween_property(array_sign[j], "position", get_new_pos(array_sign[j], Vector2(100, 0)), 0.2)
	t_in.tween_property(array_label[j], "position", get_new_pos(array_label[j], Vector2(100, 0)), 0.2)
	t_in.tween_property(array_cassette[j], "modulate:a", 1.0, 0.2)
	t_in.tween_property(array_sign[j], "modulate:a", 1.0, 0.2)
	t_in.tween_property(array_label[j], "modulate:a", 1.0, 0.2)
	await t_in.finished
	printed_cassette = j

func move_cassette_to_right(i: int) -> void:
	var t_out: Tween = create_tween().set_parallel(true)
	var j: int = (i+1)%3
	# Disparition de l'ancienne cassette
	t_out.tween_property(array_cassette[i], "position", get_new_pos(array_cassette[i], Vector2(-100, 0)), 0.2)
	t_out.tween_property(array_sign[i], "position", get_new_pos(array_sign[i], Vector2(-100, 0)), 0.2)
	t_out.tween_property(array_label[i], "position", get_new_pos(array_label[i], Vector2(-100, 0)), 0.2)
	t_out.tween_property(array_cassette[j], "position", get_new_pos(array_cassette[j], Vector2(100, 0)), 0.2)
	t_out.tween_property(array_sign[j], "position", get_new_pos(array_sign[j], Vector2(100, 0)), 0.2)
	t_out.tween_property(array_label[j], "position", get_new_pos(array_label[j], Vector2(100, 0)), 0.2)
	t_out.tween_property(array_cassette[i], "modulate:a", 0.0, 0.2)
	t_out.tween_property(array_sign[i], "modulate:a", 0.0, 0.2)
	t_out.tween_property(array_label[i], "modulate:a", 0.0, 0.2)
	await t_out.finished
	
	array_cassette[i].visible = false
	array_sign[i].visible = false
	array_label[i].visible = false
	array_cassette[j].visible = true
	array_sign[j].visible = true
	array_label[j].visible = true
	
	# Apparition de la nouvelle cassette
	var t_in: Tween = create_tween().set_parallel(true)
	t_in.tween_property(array_cassette[i], "position", get_new_pos(array_cassette[i], Vector2(100, 0)), 0.2)
	t_in.tween_property(array_sign[i], "position", get_new_pos(array_sign[i], Vector2(100, 0)), 0.2)
	t_in.tween_property(array_label[i], "position", get_new_pos(array_label[i], Vector2(100, 0)), 0.2)
	t_in.tween_property(array_cassette[j], "position", get_new_pos(array_cassette[j], Vector2(-100, 0)), 0.2)
	t_in.tween_property(array_sign[j], "position", get_new_pos(array_sign[j], Vector2(-100, 0)), 0.2)
	t_in.tween_property(array_label[j], "position", get_new_pos(array_label[j], Vector2(-100, 0)), 0.2)
	t_in.tween_property(array_cassette[j], "modulate:a", 1.0, 0.2)
	t_in.tween_property(array_sign[j], "modulate:a", 1.0, 0.2)
	t_in.tween_property(array_label[j], "modulate:a", 1.0, 0.2)
	await t_in.finished
	printed_cassette = j

func onArrows_pressed(direction: int) -> void:
	if direction == 0: move_cassette_to_left(printed_cassette)
	else: move_cassette_to_right(printed_cassette)

func _onMenuButtonEnter() -> void:
	Global.ButtonEnter(menu_button, menu_scale, false, sign_menu, sign_menu_scale)

func _onMenuButtonExit() -> void:
	Global.ButtonExit(menu_button, menu_scale, false, sign_menu, sign_menu_scale)

func _onStartButtonEnter() -> void:
	Global.ButtonEnter(start_button, start_scale, false, sign_start, sign_start_scale)

func _onStartButtonExit() -> void:
	Global.ButtonExit(start_button, start_scale, false, sign_start, sign_start_scale)

func _onBackButtonEnter() -> void:
	Global.ButtonEnter(back_button, back_scale, false, sign_back, sign_back_scale)

func _onBackButtonExit() -> void:
	Global.ButtonExit(back_button, back_scale, false, sign_back, sign_back_scale)

func _onHealMouseEnter() -> void:
	Global.ButtonEnter(heal_mode_button, heal_scale, true)

func _onHealMouseExit() -> void:
	Global.ButtonExit(heal_mode_button, heal_scale, true)

func _onTwoPlayerModePressed(toggled_on: bool) -> void:
	Global.two_player_mode = toggled_on
