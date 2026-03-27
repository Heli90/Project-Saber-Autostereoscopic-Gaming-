extends Node3D

@onready var screen_output = $TextureRect
@export var nb_views : int = 8
@onready var cube_tournant: Node3D = $CubeTournant
@onready var j1: CharacterBody3D = $J1
@onready var j2: CharacterBody3D = $J2

@onready var cam_controller_j1: Node3D = $J1/CameraControllerFPS
@onready var cam_controller_j2: Node3D = $J2/CameraControllerFPS

@onready var label_fps: Label = $TechnicalInfos/FPS
@onready var label_cpu = $TechnicalInfos/CPU
@onready var label_gpu = $TechnicalInfos/GPU
@onready var label_draw_calls = $TechnicalInfos/DrawCalls

@onready var textureRect = $TextureRect

var initialisations_joueurs: bool = false
var rendu_time: float = 0.0

func _ready():
	await get_tree().process_frame
	# On récupère le monde 3D
	var world_3d = get_viewport().world_3d
	if has_node("CubeTournant"):
		world_3d = $CubeTournant.get_world_3d()
	
	var shader_mat = screen_output.material as ShaderMaterial
	
	# On configure chaque vue
	for i in range(1, nb_views+1):
		var viewport_vue
		if i == 1 or i == 2 :
			viewport_vue = "J1/CameraControllerFPS/Vue" + str(i)
		elif i == 5 or i == 6:
			viewport_vue = "J2/CameraControllerFPS/Vue" + str(i)
		else:
			viewport_vue = "Vue" + str(i)
		if has_node(viewport_vue):
			var vue = get_node(viewport_vue) as SubViewport
			vue.world_3d = world_3d # On met en commun le monde 3D
			await get_tree().process_frame # On attend un court instant pour l'initialisation de la texture
			var texture_vue = vue.get_texture()
			var shader_vue = "vue_" + str(i)
			shader_mat.set_shader_parameter(shader_vue, texture_vue)
	var end_time = Time.get_ticks_msec()
	rendu_time = end_time - start_time
	textureRect.material.set_shader_parameter("offset", 0.0) # Initialise l'effet glitch à 0

func _process(_delta):
	# On calcule le temps final de rendu des frames en attendant que toutes les vues ont été traitées
	var start_time = Time.get_ticks_msec()
	await RenderingServer.frame_post_draw
	var end_time = Time.get_ticks_msec()
	var render_time = (end_time - start_time)
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var process_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	
	label_fps.text = "FPS: %d"%fps
	label_cpu.text = "Temps passé sur le CPU: %d ms"%process_time
	label_gpu.text = "Temps passé sur le GPU pour la frame précédente: %d ms"%render_time

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("StopGame"):
		cube_tournant._onPartieTimerTimeout()
	if event.is_action_pressed("Invert_views_J1"):
		if textureRect:
			var invert = textureRect.material.get_shader_parameter("invertViews")
			textureRect.material.set_shader_parameter("invertViews", not invert)
	if event.is_action_pressed("glitchEffect"):
		var offset = textureRect.material.get_shader_parameter("offset")
		textureRect.material.set_shader_parameter("offset", offset+0.01)
	if event.is_action_pressed("resetGlitchEffect"):
		textureRect.material.set_shader_parameter("offset", 0.0)
