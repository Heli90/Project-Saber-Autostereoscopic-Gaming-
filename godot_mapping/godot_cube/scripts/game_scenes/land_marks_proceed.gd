extends Node2D

# Variables MediaPipe
var task
var renderer
var model_path = "res://gesture_recognizer/gesture_recognizer.task"
var modulated = 1
var time_detect
var time_render
var time_display
var camera_fps


var running_mode = 1 # Mode Vidéo
var num_hands = 4
var gesture_string = "None"

# Variables Caméra
var camera_extension: CameraServerExtension
var camera_feed: CameraFeed

@onready var viewport = $SubViewportContainer/CameraViewport
@onready var texture_rect = $SubViewportContainer/CameraViewport/TestAffichage
@onready var debug_view = $CanvasLayer/DebugOverlay # Un TextureRect pour voir le résultat
@onready var cube = $".."/Cube
@onready var label: Label = $"../CameraLabel"
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
	
	task = MediaPipeGestureRecognizer.new()
	
	# Paramètres : Mode de capture (Ici 1 pour le mode vidéo) et le nombre de mains (Ici 4)
	task.initialize(options, running_mode, num_hands)
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

func _process(_delta):
	camera_fps = Engine.get_frames_per_second()
	label.text = ""
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
	var result = task.recognize(mp_image)
	assert(result.gestures.size() == result.handedness.size())
	for i in range(result.gestures.size()):
		var gesture : MediaPipeClassifications= result.gestures[i]
		var classification_gesture := gesture.categories[0]
		gesture_string = classification_gesture.category_name
	time_detect = (Time.get_ticks_usec()-start_detect)/1000.0
	
	if result:
		# Dessin des marqueurs sur les mains
		var start_render = Time.get_ticks_usec()
		var output = renderer.render(mp_image, result.hand_landmarks)
		time_render = (Time.get_ticks_usec()-start_render)/1000.0
		
		var start_display = Time.get_ticks_usec()
		update_debug_overlay(output.image)
		time_display = (Time.get_ticks_usec()-start_display)/1000.0
		
		# Traitement des mains détectées
		for i in range(result.hand_landmarks.size()):
			label.text = "Main détectée"
			var hand_landmarks = result.hand_landmarks[i]
			modulated = hand_landmarks.landmarks[8].x
			_maj_speed() # On passe l'index de la main (0 ou 1)

func _maj_speed():
	# Tout ce qui concerne la gestion des données relatives aux mains se fait ici
	#print("Coordonnées: x=%f, y=%f, z=%f" % [
	#hand_landmarks.landmarks[8].x,
	#hand_landmarks.landmarks[8].y,
	#hand_landmarks.landmarks[8].z])
	return [modulated,gesture_string]
