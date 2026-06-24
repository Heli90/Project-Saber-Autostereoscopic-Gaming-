extends Node3D

@export var nb_views : int = 8
@onready var screen_output = $TextureRect
@onready var game: Node3D = $Game
@onready var cube_spawner: Node3D = $Game/CubeSpawner
@onready var fondu_noir: ColorRect = $Game/HUD/FonduLayer/FonduNoir
@onready var landmarks_proceed: Node2D = $Game/LandMarksProceed
@onready var pause_menu: ColorRect = $Game/HUD/PauseMenu
@onready var click_sound: AudioStreamPlayer = $Game/HUD/PauseMenu/ClickSound

@onready var camera1: Camera3D = $Vue1/Camera
@onready var camera2: Camera3D = $Vue2/Camera
@onready var camera3: Camera3D = $Vue5/Camera
@onready var camera4: Camera3D = $Vue6/Camera
# Pas de décalage des caméras
var step : float = 0.01
var convergence_step : float = 0.1

@onready var sign_is_j1: Sprite2D = $Buttons/SignIS_J1
@onready var is_button_j1: Button = $Buttons/ISButton_J1
var is1_scale: Vector2
var sign_is1_scale: Vector2

@onready var sign_is_j2: Sprite2D = $Buttons/SignIS_J2
@onready var is_button_j2: Button = $Buttons/ISButton_J2
var is2_scale: Vector2
var sign_is2_scale: Vector2

@onready var sign_increase_j1: Sprite2D = $Buttons/SignIncreaseJ1
@onready var increase_j1: Button = $Buttons/Increase_J1
var inc1_scale: Vector2
var sign_inc1_scale: Vector2

@onready var sign_decrease_j1: Sprite2D = $Buttons/SignDecreaseJ1
@onready var decrease_j1: Button = $Buttons/Decrease_J1
var dec1_scale: Vector2
var sign_dec1_scale: Vector2

@onready var sign_increase_j2: Sprite2D = $Buttons/SignIncreaseJ2
@onready var increase_j2: Button = $Buttons/Increase_J2
var inc2_scale: Vector2
var sign_inc2_scale: Vector2

@onready var sign_decrease_j2: Sprite2D = $Buttons/SignDecreaseJ2
@onready var decrease_j2: Button = $Buttons/Decrease_J2
var dec2_scale: Vector2
var sign_dec2_scale: Vector2

@onready var sign_validation: Sprite2D = $Buttons/SignValidation
@onready var validation_button: Button = $Buttons/ValidationButton
var val_scale: Vector2
var sign_val_scale: Vector2

@onready var signIncreaseConv1: Sprite2D = $Buttons/SignIncreaseConvJ1
@onready var IncreaseConv1: Button = $Buttons/IncreaseConv_J1
var inconv1_scale: Vector2
var sign_inconv1_scale: Vector2

@onready var signIncreaseConv2: Sprite2D = $Buttons/SignIncreaseConvJ2
@onready var IncreaseConv2: Button = $Buttons/IncreaseConv_J2
var inconv2_scale: Vector2
var sign_inconv2_scale: Vector2

@onready var signDecreaseConv1: Sprite2D = $Buttons/SignDecreaseConvJ1
@onready var DecreaseConv1: Button = $Buttons/DecreaseConvJ1
var deconv1_scale: Vector2
var sign_deconv1_scale: Vector2

@onready var signDecreaseConv2: Sprite2D = $Buttons/SignDecreaseConvJ2
@onready var DecreaseConv2: Button = $Buttons/DecreaseConvJ2
var deconv2_scale: Vector2
var sign_deconv2_scale: Vector2

var array_IS_button: Array[Button]
var array_sign_IS_button: Array[Sprite2D]
var array_inc: Array[Button]
var array_sign_inc: Array[Sprite2D]
var array_dec: Array[Button]
var array_sign_dec: Array[Sprite2D]
var array_cam: Array[Camera3D]
var array_inconv: Array[Button]
var array_sign_inconv: Array[Sprite2D]
var array_deconv: Array[Button]
var array_sign_deconv: Array[Sprite2D]

func _ready() -> void:
	# Définition de la taille de tous les boutons et de tous les panneaux
	is1_scale = is_button_j1.scale
	sign_is1_scale = sign_is_j1.scale
	is2_scale = is_button_j2.scale
	sign_is2_scale = sign_is_j2.scale
	inc1_scale = increase_j1.scale
	sign_inc1_scale = sign_increase_j1.scale
	dec1_scale = decrease_j1.scale
	sign_dec1_scale = sign_decrease_j1.scale
	inc2_scale = increase_j2.scale
	sign_inc2_scale = sign_increase_j2.scale
	dec2_scale = decrease_j2.scale
	sign_dec2_scale = sign_decrease_j2.scale
	val_scale = validation_button.scale
	sign_val_scale = sign_validation.scale
	inconv1_scale = IncreaseConv1.scale
	sign_inconv1_scale = signIncreaseConv1.scale
	inconv2_scale = IncreaseConv2.scale
	sign_inconv2_scale = signIncreaseConv2.scale
	deconv1_scale = DecreaseConv1.scale
	sign_deconv1_scale = signDecreaseConv1.scale
	deconv2_scale = DecreaseConv2.scale
	sign_deconv2_scale = signDecreaseConv2.scale
	
	# Définition des listes de boutons
	array_IS_button = [is_button_j1, is_button_j2]
	array_inc = [increase_j1, increase_j2]
	array_dec = [decrease_j1, decrease_j2]
	array_sign_IS_button = [sign_is_j1, sign_is_j2]
	array_sign_inc = [sign_increase_j1, sign_increase_j2]
	array_sign_dec = [sign_decrease_j1, sign_decrease_j2]
	array_inconv = [IncreaseConv1, IncreaseConv2]
	array_sign_inconv = [signIncreaseConv1, signIncreaseConv2]
	array_deconv =[DecreaseConv1, DecreaseConv2]
	array_sign_deconv = [signDecreaseConv1, signDecreaseConv2]
	
	# Définition de la liste des caméras et des positions initiales
	array_cam = [camera1, camera3, camera2, camera4]
	for i in range(4): 
		array_cam[i].position.x = Global.array_cam[i]
		update_frustum(array_cam[i], step, convergence_distance)
	
	# On ne lance pas le thread de caméra au début pour optimiser les FPS
	landmarks_proceed.camera_feed.feed_is_active = false
	Input.warp_mouse(Vector2(960.0, 1080.0))
	
	# On récupère le monde 3D
	var world_3d = get_viewport().world_3d
	if has_node("Game"):
		world_3d = game.get_world_3d()
	
	var shader_mat = screen_output.material as ShaderMaterial
	# On configure chaque vue
	for i in range(1, nb_views+1):
		var viewport_vue = "Vue" + str(i)
		if has_node(viewport_vue):
			var vue = get_node(viewport_vue) as SubViewport
			vue.world_3d = world_3d # On met en commun le monde 3D
			await get_tree().process_frame # On attend un court instant pour l'initialisation de la texture
			var texture_vue = vue.get_texture()
			var shader_vue = "vue_" + str(i)
			shader_mat.set_shader_parameter(shader_vue, texture_vue)
	screen_output.material.set_shader_parameter("offset", 0.0) # Initialise l'effet glitch à 0
	screen_output.material.set_shader_parameter("pixelisation_mask", [true, true, false, false, true, true, false, false]) # Initialise les vues qui auront l'effet de pixelisation
	await get_tree().process_frame

	var t = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(fondu_noir, "modulate:a", 0.0, 0.6)
	await t.finished
	fondu_noir.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func ISButton(i: int) -> void:
	click_sound.play()
	var t_out: Tween = create_tween().set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t_out.tween_property(array_IS_button[i], "modulate:a", 0.0, 0.1)
	t_out.tween_property(array_inc[1-i], "modulate:a", 0.0, 0.1)
	t_out.tween_property(array_dec[1-i], "modulate:a", 0.0, 0.1)
	t_out.tween_property(array_sign_IS_button[i], "modulate:a", 0.0, 0.1)
	t_out.tween_property(array_sign_inc[1-i], "modulate:a", 0.0, 0.1)
	t_out.tween_property(array_sign_dec[1-i], "modulate:a", 0.0, 0.1)
	t_out.tween_property(array_inconv[1-i], "modulate:a", 0.0, 0.1)
	t_out.tween_property(array_deconv[1-i], "modulate:a", 0.0, 0.1)
	t_out.tween_property(array_sign_deconv[1-i], "modulate:a", 0.0, 0.1)
	t_out.tween_property(array_sign_inconv[1-i], "modulate:a", 0.0, 0.1)
	await t_out.finished
	
	array_IS_button[i].visible = false
	array_inc[1-i].visible = false
	array_dec[1-i].visible = false
	array_inconv[1-i].visible = false
	array_deconv[1-i].visible = false
	array_IS_button[1-i].visible = true
	array_inc[i].visible = true
	array_dec[i].visible = true
	array_inconv[i].visible = true
	array_deconv[i].visible = true
	array_sign_IS_button[i].visible = false
	array_sign_inc[1-i].visible = false
	array_sign_dec[1-i].visible = false
	array_sign_inconv[1-i].visible = false
	array_sign_deconv[1-i].visible = false
	array_sign_IS_button[1-i].visible = true
	array_sign_inc[i].visible = true
	array_sign_dec[i].visible = true
	array_sign_inconv[i].visible = true
	array_sign_deconv[i].visible = true
	
	var t_in: Tween = create_tween().set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t_in.tween_property(array_IS_button[1-i], "modulate:a", 1.0, 0.1)
	t_in.tween_property(array_inc[i], "modulate:a", 1.0, 0.1)
	t_in.tween_property(array_dec[i], "modulate:a", 1.0, 0.1)
	t_in.tween_property(array_sign_IS_button[1-i], "modulate:a", 1.0, 0.1)
	t_in.tween_property(array_sign_inc[i], "modulate:a", 1.0, 0.1)
	t_in.tween_property(array_sign_dec[i], "modulate:a", 1.0, 0.1)
	t_in.tween_property(array_inconv[i], "modulate:a", 1.0, 0.1)
	t_in.tween_property(array_deconv[i], "modulate:a", 1.0, 0.1)
	t_in.tween_property(array_sign_deconv[i], "modulate:a", 1.0, 0.1)
	t_in.tween_property(array_sign_inconv[i], "modulate:a", 1.0, 0.1)
	await t_in.finished

func _onISButton1_pressed() -> void: ISButton(0)
func _onISButton2_pressed() -> void: ISButton(1)

func Increase(i: int) -> void:
	click_sound.play()
	array_cam[i].position.x += step
	array_cam[i+2].position.x -= step
	update_frustum(array_cam[i], step, convergence_distance)
	update_frustum(array_cam[i+2], step, convergence_distance)
	Global.array_cam[i] = array_cam[i].position.x
	Global.array_cam[i+2] = array_cam[i+2].position.x

func Decrease(i: int) -> void:
	click_sound.play()
	array_cam[i].position.x -= step
	array_cam[i+2].position.x += step
	update_frustum(array_cam[i], step, convergence_distance)
	update_frustum(array_cam[i+2], step, convergence_distance)
	Global.array_cam[i] = array_cam[i].position.x
	Global.array_cam[i+2] = array_cam[i+2].position.x
	
func IncreaseConv(i:int)->void:
	click_sound.play()
	if (Global.array_convergence[i]>convergence_step and Global.array_convergence[i+1]>convergence_step):
		Global.array_convergence[i] -= convergence_step
		Global.array_convergence[i+1] -= convergence_step
	Global.update_frustum(array_cam[i], array_cam[i].position.x, Global.array_convergence[i])
	Global.update_frustum(array_cam[i+2], array_cam[i+2].position.x, Global.array_convergence[i+1])
	
func DecreaseConv(i:int)->void:
	click_sound.play()
	
	Global.array_convergence[i] += convergence_step
	Global.array_convergence[i+1] += convergence_step
	Global.update_frustum(array_cam[i], array_cam[i].position.x, Global.array_convergence[i])
	Global.update_frustum(array_cam[i+2], array_cam[i+2].position.x, Global.array_convergence[i+1])

func _onIncrease1_pressed() -> void: Increase(0)
func _onDecrease1_pressed() -> void: Decrease(0)
func _onIncrease2_pressed() -> void: Increase(1)
func _onDecrease2_pressed() -> void: Decrease(1)

func _onIncreaseConv1_pressed()-> void: IncreaseConv(0)
func _onIncreaseConv2_pressed()-> void: IncreaseConv(1)
func _onDecreaseConv1_pressed()-> void: DecreaseConv(0)
func _onDecreaseConv2_pressed()-> void: DecreaseConv(1)

func _onValidationButton_pressed() -> void:
	click_sound.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var t = create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.chain().tween_interval(0.1)
	t.tween_callback(func():
		fondu_noir.modulate.a = 0.0
		fondu_noir.visible = true)
	t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
	t.chain().tween_interval(0.3)
	await t.finished
	get_tree().paused = false
	Global.launched_mode = 0
	get_tree().change_scene_to_file("res://scenes/menus/main_menu_3d.tscn")

func _onISButton1Enter() -> void:
	Global.ButtonEnter(is_button_j1, is1_scale, false, sign_is_j1, sign_is1_scale)

func _onISButton1Exit() -> void:
	Global.ButtonExit(is_button_j1, is1_scale, false, sign_is_j1, sign_is1_scale)

func _onISButton2Enter() -> void:
	Global.ButtonEnter(is_button_j2, is2_scale, false, sign_is_j2, sign_is2_scale)

func _onISButton2Exit() -> void:
	Global.ButtonExit(is_button_j2, is2_scale, false, sign_is_j2, sign_is2_scale)

func _onIncrease1Enter() -> void:
	Global.ButtonEnter(increase_j1, inc1_scale, false, sign_increase_j1, sign_inc1_scale)

func _onIncrease1Exit() -> void:
	Global.ButtonExit(increase_j1, inc1_scale, false, sign_increase_j1, sign_inc1_scale)

func _onDecrease1Enter() -> void:
	Global.ButtonEnter(decrease_j1, dec1_scale, false, sign_decrease_j1, sign_dec1_scale)

func _onDecrease1Exit() -> void:
	Global.ButtonExit(decrease_j1, dec1_scale, false, sign_decrease_j1, sign_dec1_scale)

func _onIncrease2Enter() -> void:
	Global.ButtonEnter(increase_j2, inc2_scale, false, sign_increase_j2, sign_inc2_scale)

func _onIncrease2Exit() -> void:
	Global.ButtonExit(increase_j2, inc2_scale, false, sign_increase_j2, sign_inc2_scale)

func _onDecrease2Enter() -> void:
	Global.ButtonEnter(decrease_j2, dec2_scale, false, sign_decrease_j2, sign_dec2_scale)

func _onDecrease2Exit() -> void:
	Global.ButtonExit(decrease_j2, dec2_scale, false, sign_decrease_j2, sign_dec2_scale)

func _onValidationEnter() -> void:
	Global.ButtonEnter(validation_button, val_scale, false, sign_validation, sign_val_scale)

func _onValidationExit() -> void:
	Global.ButtonExit(validation_button, val_scale, false, sign_validation, sign_val_scale)

<<<<<<< HEAD
func _on_increase_conv_j_1_pressed() -> void: IncreaseConv(0)

func _on_increase_conv_j_1_mouse_entered() -> void:
	Global.ButtonEnter(IncreaseConv1, inconv1_scale, false, signIncreaseConv1, sign_inconv1_scale)

func _on_increase_conv_j_1_mouse_exited() -> void:
	Global.ButtonExit(IncreaseConv1, inconv1_scale, false, signIncreaseConv1, sign_inconv1_scale)

func _on_decrease_conv_j_1_pressed() -> void: DecreaseConv(0)
	
func _on_decrease_conv_j_1_mouse_entered() -> void:
	Global.ButtonEnter(DecreaseConv1, deconv1_scale, false, signDecreaseConv1, sign_deconv1_scale)

func _on_decrease_conv_j_1_mouse_exited() -> void:
	Global.ButtonExit(DecreaseConv1, deconv1_scale, false, signDecreaseConv1, sign_deconv1_scale)

func _on_increase_conv_j_2_pressed() -> void:IncreaseConv(1)

func _on_increase_conv_j_2_mouse_entered() -> void:
	Global.ButtonEnter(IncreaseConv2, inconv2_scale, false, signIncreaseConv2, sign_inconv2_scale)

func _on_increase_conv_j_2_mouse_exited() -> void:
	Global.ButtonExit(IncreaseConv2, inconv2_scale, false, signIncreaseConv2, sign_inconv2_scale)

func _on_decrease_conv_j_2_pressed() -> void: DecreaseConv(1)

func _on_decrease_conv_j_2_mouse_entered() -> void:
	Global.ButtonEnter(DecreaseConv2, deconv2_scale, false, signDecreaseConv2, sign_deconv2_scale)

func _on_decrease_conv_j_2_mouse_exited() -> void:
	Global.ButtonExit(DecreaseConv2, deconv2_scale, false, signDecreaseConv2, sign_deconv2_scale)
=======
# Calcule l'offset à mettre dans le frustum pour placer le point de convergence du regard à l'endroit souhaité
func update_frustum(cam : Camera3D, eye_offset : float, convergence:float)-> void:
	cam.projection = Camera3D.PROJECTION_FRUSTUM
	cam.frustum_offset = Vector2(eye_offset * cam.near / convergence, 0.0)
>>>>>>> effets_visuels_le_retour
