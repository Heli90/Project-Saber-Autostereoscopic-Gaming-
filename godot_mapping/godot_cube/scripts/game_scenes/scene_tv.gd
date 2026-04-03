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

@onready var textureRect = $TextureRect

var initialisations_joueurs: bool = false
var rendu_time: float = 0.0
var rd: RenderingDevice
var last_gpu_time_ms: float = 0.0

func _ready():
	rd = RenderingServer.get_rendering_device()
	await get_tree().process_frame
	# On récupère le monde 3D
	var world_3d = get_viewport().world_3d
	if has_node("CubeTournant"):
		world_3d = $CubeTournant.get_world_3d()
	
	var shader_mat = screen_output.material as ShaderMaterial
	
	var start_time = Time.get_ticks_msec()
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

func _process(_delta: float) -> void:
	# Temps total d'une frame
	var fps = Engine.get_frames_per_second()
	
	# Temps de rendu du CPU
	var cpu_time = Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	# Temps de rendu du GPU
	if rd:
		# Les timestamps sont capturés sur la frame précédente
		var count = rd.get_captured_timestamps_count()
		if count >= 2:
			# Timestamp de fin - timestamp de début = durée GPU totale
			var t_start = rd.get_captured_timestamp_gpu_time(0)
			var t_end   = rd.get_captured_timestamp_gpu_time(count - 1)
			last_gpu_time_ms = max(0.0, (t_end - t_start) / 1_000_000.0)
	
	label_fps.text = "FPS: %d"%fps
	label_cpu.text = "CPU: %.2f ms"%cpu_time
	label_gpu.text = "GPU: %.2f ms"%last_gpu_time_ms

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
