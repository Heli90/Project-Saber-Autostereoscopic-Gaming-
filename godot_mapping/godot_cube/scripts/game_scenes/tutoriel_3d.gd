extends Node3D

@export var nb_views : int = 8
@onready var screen_output = $TextureRect
@onready var game: Node3D = $Game

@onready var remote1_j1: RemoteTransform3D = $J1/CameraController/RemoteVue1
@onready var remote2_j1: RemoteTransform3D = $J1/CameraController/RemoteVue2
@onready var remote1_j2: RemoteTransform3D = $J2/CameraController/RemoteVue5
@onready var remote2_j2: RemoteTransform3D = $J2/CameraController/RemoteVue6

var rd: RenderingDevice
var last_gpu_time_ms: float = 0.0
var last_gpu_vues_ms: float = 0.0

func _ready() -> void:
	Global.launched_mode = 1

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
