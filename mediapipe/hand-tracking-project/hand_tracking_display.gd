extends Node3D

# Variables MediaPipe
var task
var renderer
var model_path = "res://hand_landmarker/hand_landmarker.task"

# Variables Caméra
var camera_extension: CameraServerExtension
var camera_feed: CameraFeed

@onready var viewport = $SubViewportContainer/CameraViewport
@onready var texture_rect = $SubViewportContainer/CameraViewport/TestAffichage
@onready var debug_view = $CanvasLayer/DebugOverlay # Un TextureRect pour voir le résultat
@onready var hand_label : Label = $CanvasLayerLabel/HandLabel
@onready var camera_fps_label : Label = $CanvasLayerLabel/CameraFPSLabel
@onready var detection_label : Label = $CanvasLayerLabel/DetectionLabel
@onready var render_label: Label = $CanvasLayerLabel/RenderLabel
@onready var display_label : Label = $CanvasLayerLabel/DisplayLabel
@onready var coordinates_display: Label = $CanvasLayerLabel/CoordinatesDisplay

func _ready():
	_setup_mediapipe()
	_setup_camera()


func _setup_mediapipe():
	# Récupère le modèle hand_landmarker.task et l'initialise
	if not FileAccess.file_exists(model_path):
		print("ERREUR : Modèle .task introuvable !")
		return
	
	# Chargement par Buffer
	var buffer = FileAccess.get_file_as_bytes(model_path)
	var options = MediaPipeTaskBaseOptions.new()
	options.model_asset_buffer = buffer
	
	task = MediaPipeHandLandmarker.new()
	
	# Paramètres : Mode de capture (Ici 1 pour le mode vidéo) et le nombre de mains (Ici 4)
	task.initialize(options, 1,4)
	renderer = MediaPipeHandRenderer.new()
	print("MediaPipe initialisé.")

func _setup_camera():
	# Ouverture de la caméra
	if OS.get_name() in ["Windows", "iOS"]:
		camera_extension = CameraServerExtension.new()
		camera_extension.permission_result.connect(self._on_permission)
		if not camera_extension.permission_granted():
			camera_extension.request_permission()
		else:
			_start_camera()
	else:
		_start_camera()

func _on_permission(granted):
	if granted: _start_camera()

func _start_camera():
	# Applique ce que voit la caméra à TestAffichage (TextureReact)
	await get_tree().create_timer(0.5).timeout
	CameraServer.monitoring_feeds = true
	var feeds = CameraServer.feeds()
	if feeds.size() > 0:
		camera_feed = feeds[0]
		camera_feed.feed_is_active = true
		
		var tex = CameraTexture.new()
		tex.camera_feed_id = camera_feed.get_id()
		tex.which_feed = CameraServer.FEED_RGBA_IMAGE
		texture_rect.texture = tex
		print("Affichage réussi")

func update_debug_overlay(image: Image) -> void:
	image.convert(Image.FORMAT_RGB8)
	if debug_view.texture == null :
		debug_view.texture = ImageTexture.create_from_image(image)
	else :
		if Vector2i(debug_view.texture.get_size()) == image.get_size():
			debug_view.texture.update(image)
		else:
			debug_view.texture.set_image(image)

func _on_hand_data_received(hand_landmarks, hand_index):
	# Tout ce qui concerne la gestion des données relatives aux mains se fait ici
	coordinates_display.text = "Coordonnées: x=%.3f, y=%.3f, z=%.3f\n Hand_index : %d" % [
	hand_landmarks.landmarks[8].x,
	hand_landmarks.landmarks[8].y,
	hand_landmarks.landmarks[8].z, hand_index]


func _process(_delta):
	var current_fps = Engine.get_frames_per_second()
	camera_fps_label.text = "Camera FPS : %d fps" % [current_fps]
	
	hand_label.text = "Mains : 0"
	# Récupération de l'image du Viewport
	var tex = viewport.get_texture()
	var img = tex.get_image()
	if not img: return
	
	# Conversion pour MediaPipe
	img.convert(Image.FORMAT_RGBA8)
	var mp_image = MediaPipeImage.new()
	mp_image.set_image(img)
	
	# Détection des mains
	var start_detect = Time.get_ticks_usec()
	var result = task.detect(mp_image)
	var time_dectect = (Time.get_ticks_usec()-start_detect)/1000.0
	detection_label.text = "Time_detect AI : %.2f ms" % [time_dectect]
	
	
	if result:
		# Dessin des marqueurs sur les mains
		var start_render = Time.get_ticks_usec()
		var output = renderer.render(mp_image, result.hand_landmarks)
		var time_render = (Time.get_ticks_usec()-start_render)/1000.0
		render_label.text = "MediaPipe Render Time : %.2f ms" % [time_render]
		
		var start_display = Time.get_ticks_usec()
		update_debug_overlay(output.image)
		var time_display = (Time.get_ticks_usec()-start_display)/1000.0
		display_label.text = "Display Time : %.2f ms" % [time_display]
		
		# Traitement des mains détectés
		var size = result.hand_landmarks.size()
		for i in range(size):
			hand_label.text = "Mains : %d" % [size]
			var hand_landmarks = result.hand_landmarks[i]
			_on_hand_data_received(hand_landmarks, i) # On passe l'index de la main (0 ou 1)
