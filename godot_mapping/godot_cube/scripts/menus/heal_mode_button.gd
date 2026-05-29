extends TextureButton

@export var full_heart: Texture2D
@export var empty_heart: Texture2D

var activated: bool = false

func _ready() -> void:
	texture_normal = empty_heart
	# On crée la zone de collision du bouton sur l'image du coeur uniquement
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(full_heart.get_image())
	texture_click_mask = bitmap
