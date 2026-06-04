extends Node3D

@export var nb_views : int = 8
@onready var screen_output = $TextureRect
@onready var game: Node3D = $Game
@onready var j1: Node3D = $J1
@onready var j2: Node3D = $J2

@onready var remote1_j1: RemoteTransform3D = $J1/CameraController/RemoteVue1
@onready var remote2_j1: RemoteTransform3D = $J1/CameraController/RemoteVue2
@onready var remote1_j2: RemoteTransform3D = $J2/CameraController/RemoteVue5
@onready var remote2_j2: RemoteTransform3D = $J2/CameraController/RemoteVue6

@onready var label_fps: Label = $TechnicalInfos/FPS
@onready var label_cpu = $TechnicalInfos/CPU
@onready var label_gpu = $TechnicalInfos/GPU
@onready var label_gpu_entrelacement: Label = $TechnicalInfos/GPUEntrelacement
@onready var label_gpu_vues: Label = $TechnicalInfos/GPUVues

@onready var label_detect_mediapipe: Label = $TechnicalInfos/DetectMediapipe
@onready var land_marks_proceed: Node2D = $Game/LandMarksProceed

var rd: RenderingDevice
var last_gpu_time_ms: float = 0.0
var last_gpu_vues_ms: float = 0.0

func _ready() -> void:
	Global.launched_mode = 2

	rd = RenderingServer.get_rendering_device()
	await get_tree().process_frame
	# On récupère le monde 3D
	var world_3d = get_viewport().world_3d
	if has_node("Game"):
		world_3d = game.get_world_3d()
	
	var shader_mat = screen_output.material as ShaderMaterial
	# On configure chaque vue
	for i in range(1, nb_views+1):
		var viewport_vue
		if i == 1 or i == 2 :
			viewport_vue = "J1/CameraController/Vue" + str(i)
		elif i == 5 or i == 6:
			viewport_vue = "J2/CameraController/Vue" + str(i)
		else:
			viewport_vue = "Vue" + str(i)
		if has_node(viewport_vue):
			var vue = get_node(viewport_vue) as SubViewport
			vue.world_3d = world_3d # On met en commun le monde 3D
			await get_tree().process_frame # On attend un court instant pour l'initialisation de la texture
			var texture_vue = vue.get_texture()
			var shader_vue = "vue_" + str(i)
			shader_mat.set_shader_parameter(shader_vue, texture_vue)
	screen_output.material.set_shader_parameter("offset", 0.0) # Initialise l'effet glitch à 0
	screen_output.material.set_shader_parameter("pixelisation_mask", [true, true, false, false, true, true, false, false]) # Initialise les vues qui auront l'effet de pixelisation

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
			# Durée totale utilisée par le GPU
			var t_start = rd.get_captured_timestamp_gpu_time(0)
			var t_end   = rd.get_captured_timestamp_gpu_time(count - 1)
			last_gpu_time_ms = max(0.0, (t_end - t_start) / 1_000_000.0)
			
			# Durée spécifique pour chaque viewport et l'entrelacement
			var viewport_timestamps = []
			for i in range(1, count):
				var nom = rd.get_captured_timestamp_name(i)
				if "Render Viewport " in nom:
					viewport_timestamps.append({"name": name, "time": rd.get_captured_timestamp_gpu_time(i)})
			for i in range(1, viewport_timestamps.size()):
				var rendu_time = max(0.0, (viewport_timestamps[i]["time"] - viewport_timestamps[i-1]["time"]) / 1_000_000.0)
				if i == viewport_timestamps.size() - 1:
					label_gpu_entrelacement.text = "Entrelacement: %.2f ms"%rendu_time
				else:
					last_gpu_vues_ms += rendu_time

	label_fps.text = "FPS: %d"%fps
	label_cpu.text = "CPU: %.2f ms"%cpu_time
	label_gpu.text = "GPU (Temps total): %.2f ms"%last_gpu_time_ms
	label_gpu_vues.text = "GPU (Temps des vues): %.2f ms"%last_gpu_vues_ms
	label_detect_mediapipe.text = "Temps de détection Mediapipe : %.2f ms"%(land_marks_proceed.time_detect)
	# On réinitialise le temps cumulé des 8 vues
	last_gpu_vues_ms = 0.0

func _physics_process(_delta: float) -> void:
	# On contrôle le décalage de positions entre les caméras de chacun des joueurs
	var step : float = 0.01
	if Input.is_action_just_pressed("BringCloserCamJ1"):
		remote1_j1.position.x += step
		remote2_j1.position.x -= step
	elif Input.is_action_just_pressed("MoveAwayCamJ1"):
		remote1_j1.position.x -= step
		remote2_j1.position.x += step
	elif Input.is_action_just_pressed("BringCloserCamJ2"):
		remote1_j2.position.x += step
		remote2_j2.position.x -= step
	elif Input.is_action_just_pressed("MoveAwayCamJ2"):
		remote1_j2.position.x -= step
		remote2_j2.position.x += step

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("StopGame"):
		game.onPartieTimerTimeout()
	if event.is_action_pressed("Invert_views_J1"):
		if screen_output:
			var invert = screen_output.material.get_shader_parameter("invertViews")
			screen_output.material.set_shader_parameter("invertViews", not invert)
	if event.is_action_pressed("glitchEffect"):
		var offset = screen_output.material.get_shader_parameter("offset")
		screen_output.material.set_shader_parameter("offset", offset+0.01)
	if event.is_action_pressed("resetGlitchEffect"):
		screen_output.material.set_shader_parameter("offset", 0.0)
	if event.is_action_pressed("pixelisation"):
		var pixelisationPower = screen_output.material.get_shader_parameter("pixelisationPower")
		screen_output.set_shader_parameter("pixelisation", true)
		screen_output.set_shader_parameter("pixelisationPower", pixelisationPower-10.0)
	if event.is_action_pressed("resetPixelisation"):
		screen_output.set_shader_parameter("pixelisation", false)
		screen_output.set_shader_parameter("pixelisationPower", 200.0)
