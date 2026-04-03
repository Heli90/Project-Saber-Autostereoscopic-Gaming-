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
	# Applique ce que voit la caméra à TEstAffichage (TextureReact)
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

func _process(_delta):
	# Récupération de l'image du Viewport
	var tex = viewport.get_texture()
	var img = tex.get_image()
	if not img: return
	
	# Conversion pour MediaPipe
	img.convert(Image.FORMAT_RGBA8)
	var mp_image = MediaPipeImage.new()
	mp_image.set_image(img)
	
	# Détection des mains
	var result = task.detect(mp_image)
	
	if result:
		# Dessin des marqueurs sur les mains
		var output = renderer.render(mp_image, result.hand_landmarks)
		debug_view.texture = ImageTexture.create_from_image(output.image)
		
		# Traitement des mains détectés
		for i in range(result.hand_landmarks.size()):
			var hand_landmarks = result.hand_landmarks[i]
			_on_hand_data_received(hand_landmarks, i) # On passe l'index de la main (0 ou 1)

func _on_hand_data_received(hand_landmarks, hand_index):
	# Tout ce qui concerne la gestion des données relatives aux mains se fait ici
	print("Coordonnées: x=%f, y=%f, z=%f" % [
	hand_landmarks.landmarks[8].x,
	hand_landmarks.landmarks[8].y,
	hand_landmarks.landmarks[8].z])
	print("Main", hand_index)
