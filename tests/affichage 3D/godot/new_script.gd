extends Node

@onready var viewPortGauche = $ViewPortGauche
@onready var viewPortDroit = $ViewPortDroit
@onready var finalViewMesh = $FinalViewMesh

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Associe les caméras aux viewports
	viewPortGauche.camera = $Camera3DGauche
	viewPortDroit.camera = $Camera3DDroit

	
	# Mets les textures des viewports dans un texture pour faire des calculs avec
	var textureGauche = viewPortGauche.get_texture()
	var textureDroit = viewPortDroit.get_texture()
	
	# Shaders
	var shader_material = finalViewMesh.material_override as ShaderMaterial
	shader_material.set_shader_parameter("texture_gauche", textureGauche)
	shader_material.set_shader_parameter("texture_droit", textureDroit)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
