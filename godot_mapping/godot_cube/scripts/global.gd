extends Node

# Booléen décidant si le mode avec vie limitée est activé
var healing: bool = false
# Menu : 0 / Tutoriel : 1 / Partie : 2 / Test d'effets : 3 / Réglage d'espace interoculaire : 4
var launched_mode: int = 0
# Cubes classiques : 0 / Cubes bonus : 1 / Cubes classiques et bonus : 2 / Tous les cubes : 3
var tutoriel_played_mode: int = -1
# Booléen décidant s'il faut préparer des cubes bien précis pour le tutoriel
var setup_tutoriel: bool = true
# Facile : 0 / Moyen : 1 / Difficile : 2
var difficulty: int = 1

# Transitions associées au hover des boutons du menu
const BUTTON_SCALE_FACTOR: float = 1.01
const HEART_SCALE_FACTOR: float = 1.025
const SCALE_DURATION: float = 0.4
var first_scale_transition: Tween
var loop_scale_transition_button: Tween
var loop_scale_transition_sign: Tween

# Tableau de textures d'encre globaux
var ink_texture_list : Array = []
var ink_small_texture_list : Array = []

# Tableau associé au décalage interoculaire de chaque joueur
# L'ordre est le suivant : la caméra 1 de chaque joueur, puis la caméra 2 de chaque joueur
var array_cam = [-0.03, -0.03, 0.03, 0.03]

# Variables associées à l'amplitude des bras de chaque joueur
var alpha1: float = 2.0
var alpha2 : float = 2.0
var midx1 : float = 0.5
var midx2 : float = 0.5
var beta1 : float = 3.0
var beta2 : float = 3.0
var midy1 : float = 0.3
var midy2 : float = 0.3
var is_camera_visible : bool = false
var two_player_mode : bool = true

func ButtonEnter(button, button_scale: Vector2, life: bool = false, sign_sprite: Sprite2D = null,  sign_scale: Vector2 = Vector2(0, 0)) -> void:
	if first_scale_transition: first_scale_transition.kill()
	if loop_scale_transition_button: loop_scale_transition_button.kill()
	if loop_scale_transition_sign: loop_scale_transition_sign.kill()
	if not life: button.material.set_shader_parameter("is_hovered", true)
	
	first_scale_transition = create_tween().set_parallel(true)
	first_scale_transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	first_scale_transition.set_ease(Tween.EASE_OUT)
	first_scale_transition.set_trans(Tween.TRANS_BACK)
	if life: first_scale_transition.tween_property(button, "scale", button_scale * HEART_SCALE_FACTOR, SCALE_DURATION)
	else: first_scale_transition.tween_property(button, "scale", button_scale * BUTTON_SCALE_FACTOR, SCALE_DURATION)
	if sign_sprite: first_scale_transition.tween_property(sign_sprite, "scale", sign_scale * (BUTTON_SCALE_FACTOR), SCALE_DURATION)
	await first_scale_transition.finished
	
	loop_scale_transition_button = create_tween().set_loops()
	loop_scale_transition_button.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
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
		loop_scale_transition_sign.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		loop_scale_transition_sign.set_ease(Tween.EASE_OUT)
		loop_scale_transition_sign.set_trans(Tween.TRANS_BACK)
		loop_scale_transition_sign.tween_property(sign_sprite, "scale", sign_scale / (BUTTON_SCALE_FACTOR ** 2), SCALE_DURATION / 2)
		loop_scale_transition_sign.tween_property(sign_sprite, "scale", sign_scale * (BUTTON_SCALE_FACTOR ** 2), SCALE_DURATION * 2)

func ButtonExit(button, button_scale: Vector2, life: bool = false, sign_sprite: Sprite2D = null, sign_scale: Vector2 = Vector2(0, 0)) -> void:
	if first_scale_transition: first_scale_transition.kill()
	if loop_scale_transition_button: loop_scale_transition_button.kill()
	if loop_scale_transition_sign: loop_scale_transition_sign.kill()
	if not life: button.material.set_shader_parameter("is_hovered", false)
	
	var out = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	out.set_ease(Tween.EASE_OUT)
	out.set_trans(Tween.TRANS_SINE)
	out.set_parallel(true)
	out.tween_property(button, "scale", button_scale, SCALE_DURATION)
	if sign_sprite: out.tween_property(sign_sprite, "scale", sign_scale, SCALE_DURATION)
