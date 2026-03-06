extends Node3D

@onready var screen_output = $TextureRect
@export var nb_views : int = 8
@onready var cube_tournant: Node3D = $CubeTournant
@onready var j1: CharacterBody3D = $J1
@onready var j2: CharacterBody3D = $J2

@onready var cam_controller_j1: Node3D = $J1/CameraControllerFPS
@onready var cam_controller_j2: Node3D = $J2/CameraControllerFPS

var initialisations_joueurs: bool = false

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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("StopGame"):
		cube_tournant._onPartieTimerTimeout()
