extends Node2D

var ink_splashs : Array = []
var ink_active : bool = false
var ink_timer : float = 0.0
var ink_duration : float = 3.0

# Tableau de textures d'encre
var ink_texture_list : Array = []
var ink_small_texture_list : Array = []
const TEX_MIN = 300
const TEX_MAX = 500
const TEX_SMALL_MIN = 40
const TEX_SMALL_MAX = 120

func _ready():
	# 10 éclaboussures d'encre générées
	for i in range(10):
		var tex_size = randi_range(TEX_MIN, TEX_MAX)
		ink_texture_list.append(create_ink_texture(tex_size))
	for i in range(20):
		var tex_size = randi_range(TEX_SMALL_MIN, TEX_SMALL_MAX)
		ink_small_texture_list.append(create_ink_texture(tex_size))

func create_ink_texture(size: int) -> ImageTexture:
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.seed = randi()
	noise.frequency = 0.008
	noise.fractal_octaves = 5
	
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center = Vector2(size / 2.0, size / 2.0)
	var radius = size / 2.0
	
	for x in range(size):
		for y in range(size):
			var dist = Vector2(x, y).distance_to(center) / radius
			var n = (noise.get_noise_2d(x, y) + 1.0) / 2.0
			var edge = 0.55 + n * 0.45
			
			if dist < edge * 0.75:
				img.set_pixel(x, y, Color(0, 0, 0, 1.0))
			elif dist < edge:
				var alpha = 1.0 - smoothstep(edge * 0.75, edge, dist)
				img.set_pixel(x, y, Color(0, 0, 0, alpha))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))

	return ImageTexture.create_from_image(img)

func trigger_ink():
	ink_active = true
	ink_timer = ink_duration
	spawn_splatchs()

func spawn_splatchs():
	for child in get_children():
		if child is TextureRect:
			child.queue_free()
	ink_splashs.clear()
	
	var screen = get_viewport().get_visible_rect().size
	ink_texture_list.shuffle()
	
	var big_splash_positions: Array = []
	var count = randi_range(5, 10)
	for i in range(count):
		var splash = TextureRect.new()
		var tex = ink_texture_list[i % ink_texture_list.size()]
		var tex_size = tex.get_size().x
		
		splash.texture = tex
		splash.modulate = Color(0.0, 0.0, 0.0, randf_range(0.85, 1.0))
		splash.size = Vector2(tex_size, tex_size)
		splash.pivot_offset = splash.size / 2
		splash.rotation = randf_range(0, TAU)
		splash.position = Vector2(
			randf_range(screen.x * 0.1, screen.x * 0.9) - tex_size / 2.0,
			randf_range(screen.y * 0.05, screen.y * 0.7) - tex_size / 2.0
		)
		add_child(splash)
		big_splash_positions.append(splash.position + Vector2(tex_size, tex_size) / 2.0)
		ink_splashs.append(splash)

	var small_count = randi_range(8, 15)
	for i in range(small_count):
		var splash = TextureRect.new()
		var tex = ink_small_texture_list[i % ink_small_texture_list.size()]
		var tex_size = tex.get_size().x

		# On choisit une grande tache au hasard comme point d'origine
		var origin : Vector2 = big_splash_positions[randi() % big_splash_positions.size()]
		# On disperse autour dans un rayon de 100 à 300 pixels
		var angle = randf_range(0, TAU)
		var dist = randf_range(100, 300)
		
		splash.texture = tex
		splash.modulate = Color(0.0, 0.0, 0.0, randf_range(0.6, 1.0))
		splash.size = Vector2(tex_size, tex_size)
		splash.pivot_offset = splash.size / 2
		splash.rotation = randf_range(0, TAU)
		splash.position = origin + Vector2(cos(angle), sin(angle)) * dist - Vector2(tex_size, tex_size) / 2.0
		add_child(splash)
		ink_splashs.append(splash)

func _process(delta):
	if not ink_active: return
	ink_timer -= delta

	# On fait une disparition progressive des taches
	if ink_timer < 1.0:
		for splash in ink_splashs:
			if is_instance_valid(splash):
				splash.modulate.a = ink_timer

	# On fait entièrement disparaître les taches
	if ink_timer <= 0.0:
		ink_active = false
		for splash in ink_splashs:
			if is_instance_valid(splash):
				splash.queue_free()
		ink_splashs.clear()
