extends Node3D

@onready var screen_output = $TextureRect
@export var nb_views : int = 8

func _ready():
	# On récupère le monde 3D
	var world_3d = get_viewport().world_3d
	if has_node("CubeTournant"):
		world_3d = $CubeTournant.get_world_3d()
	
	var shader_mat = screen_output.material as ShaderMaterial
	
	# On configure chaque vue
	for i in range(1, nb_views+1):
		var viewport_vue = "Vue" + str(i)
		if has_node(viewport_vue):
			var vue = get_node(viewport_vue) as SubViewport
			viewport_vue.world_3d = world_3d # On met en commun le monde 3D
			await get_tree().process_frame # On attend un court instant pour l'initialisation de la texture
			var texture_vue = viewport_vue.get_texture()
			var shader_vue = "vue_" + str(i)
			shader_mat.set_shader_parameter(shader_vue, texture_vue)
