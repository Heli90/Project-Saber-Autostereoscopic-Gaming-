extends Node2D

# Variables MediaPipe
var task
var renderer
var model_path = "res://pose_landmarker/pose_landmarker_full.task"
var modulated = 1
var time_detect: float
var time_render: float
var time_display: float
var camera_fps
var output_image : Image = null
var last_body_detected_time : float = -999.0
var hand_display_duration : float = 0.05

# Thread
var thread_mp: Thread
var runThread : bool = true

var running_mode = 1 # Mode Vidéo
var num_pose = 2

# Variables Caméra
var camera_extension: CameraServerExtension
var camera_feed: CameraFeed
var mutex : Mutex
var image_mediapipe : Image = null
var result_mediapipe = null
var hand_data : Array = []

@onready var viewport = $SubViewportContainer/CameraViewport
@onready var texture_rect = $SubViewportContainer/CameraViewport/TestAffichage
@onready var debug_view = $CanvasLayer/DebugOverlay # Un TextureRect pour voir le résultat
@onready var label: Label = $"../CameraLabel"
@onready var confirmation_dialog: ConfirmationDialog = $SelectCamera
@onready var selected_feed: OptionButton = $SelectCamera/VBoxContainer/HBoxContainer/SelectedFeed
@onready var selected_format: OptionButton = $SelectCamera/VBoxContainer/SelectedFormat

func _ready():
	thread_mp=Thread.new()
	mutex = Mutex.new()
	thread_mp.start(_thread_mediapipe)
	_setup_camera_selection()
	_setup_camera_permissions()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _setup_mediapipe():
	# Récupère le modèle hand_landmarker.task et l'initialise
	if not FileAccess.file_exists(model_path):
		print("ERREUR : Modèle .task introuvable !")
		return
	
	# Chargement par Buffer
	var buffer = FileAccess.get_file_as_bytes(model_path)
	var options = MediaPipeTaskBaseOptions.new()
	options.model_asset_buffer = buffer
	
	task = MediaPipePoseLandmarker.new()
	
	# Paramètres : Mode de capture (Ici 1 pour le mode vidéo) et le nombre de mains (Ici 4)
	task.initialize(options, running_mode, num_pose)
	renderer = MediaPipePoseRenderer.new()
	print("MediaPipe initialisé.")

func _setup_camera_selection():
	# Configuration du dialogue
	confirmation_dialog.get_ok_button().disabled = true
	
	# Signal système pour détecter les changements de caméras
	CameraServer.camera_feeds_updated.connect(self._update_camera_list)
	
func _update_camera_list():
	selected_feed.clear()
	var feeds = CameraServer.feeds()
	
	print("Taille feed : ", feeds.size())
	
	if feeds.size() == 0:
		selected_feed.add_item("Aucune caméra trouvée")
		selected_feed.disabled = true
	else:
		selected_feed.disabled = false
		for feed in feeds:
			selected_feed.add_item(feed.get_name(), feed.get_id())
	
	selected_feed.selected = -1

func _setup_camera_permissions():
	if camera_extension:
		return
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

func _open_camera_selection():
	CameraServer.monitoring_feeds = true
	_update_camera_list()
	confirmation_dialog.popup_centered()
	
func _on_camera_selected(index: int):
	selected_format.clear()
	# On débloque le bouton OK dès qu'une caméra est sélectionnée !
	confirmation_dialog.get_ok_button().disabled = false
	
	var id = selected_feed.get_item_id(index)
	for feed in CameraServer.feeds():
		if feed.get_id() == id:
			camera_feed = feed
			break
			
	if camera_feed:
		# On tente de récupérer les formats, mais on ne bloque pas si ça échoue
		var formats = camera_feed.get_formats()
		if formats.size() > 0:
			for i in range(formats.size()):
				var f = formats[i]
				var w = f.get("width", 0)
				var h = f.get("height", 0)
				selected_format.add_item("%dx%d" % [w, h], i)
		else:
			selected_format.add_item("Format auto (Défaut)")
		
		selected_format.selected = 0 # On sélectionne le premier par défaut

func _on_format_selected(index: int):
	if camera_feed == null: return
	
	# On tente d'appliquer le format, mais on ne désactive pas le bouton OK en cas d'échec
	if not camera_feed.set_format(index, {}):
		print("Note : Le format spécifique n'a pas pu être forcé, Godot utilisera le mode natif.")

func _start_camera():
	if camera_feed == null:
		CameraServer.monitoring_feeds = true
		for feed in CameraServer.feeds():
			if feed.get_name() == "USB Video Device" :
				camera_feed = feed
		if camera_feed == null: 
			camera_feed = CameraServer.feeds()[0]
	
	# Gestion de l'effet miroir (Auto-flip si caméra frontale)
	texture_rect.flip_h = (camera_feed.get_position() != CameraFeed.FEED_BACK)
	
	camera_feed.feed_is_active = true
	
	# Création de la texture selon le type de flux
	var tex = CameraTexture.new()
	tex.camera_feed_id = camera_feed.get_id()
	
	# Support du YUV si nécessaire (comme dans VisionTask)
	if camera_feed.get_datatype() == CameraFeed.FEED_RGB:
		tex.which_feed = CameraServer.FEED_RGBA_IMAGE
	else:
		tex.which_feed = CameraServer.FEED_YCBCR_IMAGE
		# Note: Pour un rendu parfait YUV, il faudrait appliquer le shader de VisionTask ici
		
	texture_rect.texture = tex
	print("Caméra démarrée : ", camera_feed.get_name())

func reload_camera_selection():
	# On s'assure que le monitoring est actif
	CameraServer.monitoring_feeds = true
	
	# On désactive le flux actuel pour libérer le périphérique
	if camera_feed:
		camera_feed.feed_is_active = false
	
	# On force la mise à jour de la liste manuellement avant d'ouvrir
	_update_camera_list()
	
	# On configure le dialogue
	confirmation_dialog.get_ok_button().disabled = true
	confirmation_dialog.popup_centered()

func update_debug_overlay(image: Image) -> void:
	image.convert(Image.FORMAT_RGB8)
	if debug_view.texture == null :
		debug_view.texture = ImageTexture.create_from_image(image)
	else :
		if Vector2i(debug_view.texture.get_size()) == image.get_size():
			debug_view.texture.update(image)
		else:
			debug_view.texture.set_image(image)

func _thread_mediapipe():
	_setup_mediapipe()
	
	while runThread:
		var img = null
		
		#Récupération de l'image
		mutex.lock()
		if image_mediapipe:
			img = image_mediapipe
			image_mediapipe = null
		mutex.unlock()
		
		if img:
			# Conversion pour MediaPipe
			var mp_image = MediaPipeImage.new()
			mp_image.set_image(img)
			
			# Détection des mains
			var start_detect = Time.get_ticks_usec()
			var result = task.detect(mp_image)
			time_detect = (Time.get_ticks_usec()-start_detect)/1000.0
			
			if result:
				# Dessin des marqueurs sur les mains
				var start_render = Time.get_ticks_usec()
				var output = renderer.render(mp_image, result.pose_landmarks)
				time_render = (Time.get_ticks_usec()-start_render)/1000.0
				
				mutex.lock()
				output_image = output.image
				mutex.unlock()
				
				# Envoie de result au main process
				mutex.lock()
				result_mediapipe = result
				result = null
				mutex.unlock()

func _process(_delta):
	camera_fps = Engine.get_frames_per_second()
	label.text = ""

	# Récupération et affichage de l'image de rendu MediaPipe
	var out_img = null
	mutex.lock()
	out_img = output_image
	output_image = null
	mutex.unlock()
	if out_img:
		update_debug_overlay(out_img)

	# Récupération de l'image du Viewport
	var tex = viewport.get_texture()
	var img = tex.get_image()
	if not img: return
	
	# Transmission au thread
	img.convert(Image.FORMAT_RGBA8)
	mutex.lock()
	image_mediapipe = img
	mutex.unlock()
	
	# Récupération des résultats du thread
	var result = null
	mutex.lock()
	result = result_mediapipe
	result_mediapipe = null
	mutex.unlock()
	
	# Traitement des mains détectées
	if result:
		hand_data = []
		for i in range(result.pose_landmarks.size()) :
			last_body_detected_time = Time.get_ticks_msec() / 1000.0
			var pose_landmarks = result.pose_landmarks[i]
			modulated = pose_landmarks.landmarks[15].x
			var lm = pose_landmarks.landmarks
			
			# A CHANGER !!!
			var wrist_r  := Vector3(lm[15].x, lm[15].y,lm[15].z)
			var elbow_r  := Vector3(lm[13].x, lm[13].y,lm[13].z)
			var dir_r    := (wrist_r - elbow_r).normalized()
			
			var wrist_l  := Vector3(lm[16].x, lm[16].y,lm[16].z)
			var elbow_l  := Vector3(lm[14].x, lm[14].y,lm[14].z)
			var dir_l    := (wrist_l - elbow_l).normalized()
			hand_data.append({"x" : lm[16].x, "y" : lm[16].y,
			"angle_z": atan2(dir_l.y, dir_l.x), "handedness": "Left", "index" : i+1, "tilt" : atan2(dir_l.z,dir_l.y)})
			# print("Left dir : ", (180/atan2(0, -1))*atan2(dir_l.y, dir_l.x))
			hand_data.append({"x" : lm[15].x, "y" : lm[15].y,
			"angle_z": atan2(dir_r.y, dir_r.x), "handedness": "Right", "index" : i+1, "tilt" : atan2(dir_r.z,dir_r.y)})
			# print("Right dir : ", (180/atan2(0, -1))*atan2(dir_r.y, dir_r.x))
			
			_maj_speed() 
	
	# On évite de changer le texte trop vite même si on perd quelques frames à cause du thread
	if Time.get_ticks_msec() / 1000.0 - last_body_detected_time < hand_display_duration:
		label.text = "Corps détecté"
	else:
		label.text = ""

func _maj_speed():
	# Tout ce qui concerne la gestion des données relatives aux mains se fait ici
		# print("Coordonnées: x=%f, y=%f, z=%f" % [
		# hand_landmarks.landmarks[8].x,
		# hand_landmarks.landmarks[8].y,
		# hand_landmarks.landmarks[8].z])
	return [modulated]

func _exit_tree() -> void:
	runThread = false
	if thread_mp:
		thread_mp.wait_to_finish()
