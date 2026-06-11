extends Node2D

# Variables MediaPipe
var task
var renderer
var model_path = "res://pose_landmarker/pose_landmarker_full.task"
var modulated = 1
var time_detect: float = 0.0
var time_render: float = 0.0
var time_display: float = 0.0
var camera_fps = 0.0
var output_image : Image = null
var last_body_detected_time : float = -999.0
var hand_display_duration : float = 0.05

# Thread
var thread_mp: Thread
var runThread : bool = true

var running_mode = 1 # Mode Vidéo
var num_pose = 1

# Variables Caméra
var camera_extension: CameraServerExtension
var camera_feed: CameraFeed
var mutex : Mutex
var image_mediapipe : Image = null
var result_mediapipe = null
var hand_data : Array = []
var is_debug_visible : bool = false

@onready var viewport = $SubViewportContainer/CameraViewport
@onready var texture_rect = $SubViewportContainer/CameraViewport/TestAffichage
@onready var debug_view = $CanvasLayer/DebugOverlay # Un TextureRect pour voir le résultat
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
	# Récupère le modèle pose_landmarker.task et l'initialise
	if not FileAccess.file_exists(model_path):
		print("ERREUR : Modèle .task introuvable !")
		return
	
	# Chargement par Buffer
	var buffer = FileAccess.get_file_as_bytes(model_path)
	var options = MediaPipeTaskBaseOptions.new()
	options.model_asset_buffer = buffer
	
	task = MediaPipePoseLandmarker.new()
	
	# Paramètres : Mode de capture (Ici 1 pour le mode vidéo) et le nombre de corps (Ici 1 corps par moitié d'image)
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
	
	if Global.launched_mode == 2: camera_feed.feed_is_active = true
	else: camera_feed.feed_is_active = false
	
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
	if camera_feed: camera_feed.feed_is_active = false
	
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
		var full_img = null
		mutex.lock()
		if image_mediapipe:
			full_img = image_mediapipe
			image_mediapipe = null
		mutex.unlock()
		
		if full_img:
			# Découpage de l'image en deux
			var size = full_img.get_size()
			var half_width = size.x / 2
			
			# Phase Détection
			var start_detect = Time.get_ticks_usec()
			# --- Détection JOUEUR 1 (Gauche) ---
			
			var img_left = full_img.get_region(Rect2i(0, 0, half_width, size.y))
			var mp_img_left = MediaPipeImage.new()
			mp_img_left.set_image(img_left)
			var res_left = task.detect(mp_img_left)
			
			# --- Détection JOUEUR 2 (Droite) ---
			var img_right = full_img.get_region(Rect2i(half_width, 0, half_width, size.y))
			var mp_img_right = MediaPipeImage.new()
			mp_img_right.set_image(img_right)
			var res_right = task.detect(mp_img_right)
			
			time_detect = (Time.get_ticks_usec() - start_detect)/1000.0

			# On regroupe les résultats pour le process principal
		
			# Pour le debug, on recréer une image combinée avec les squelettes
			if res_left or res_right:
				if is_debug_visible :
					var start_render = Time.get_ticks_usec()
					var out_left = renderer.render(mp_img_left, res_left.pose_landmarks if res_left else [])
					var out_right = renderer.render(mp_img_right, res_right.pose_landmarks if res_right else [])
					time_render = (Time.get_ticks_usec()-start_render)/1000.0
				
					mutex.lock()
					var start_combining = Time.get_ticks_usec()
					var combined_out = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
					combined_out.blit_rect(out_left.image, Rect2i(0, 0, half_width, size.y), Vector2i(0, 0))
					combined_out.blit_rect(out_right.image, Rect2i(0, 0, half_width, size.y), Vector2i(half_width, 0))
					output_image = combined_out
					time_display = (Time.get_ticks_usec()-start_combining)/1000.0
					mutex.unlock()
				
				mutex.lock()
				result_mediapipe = {"left": res_left, "right": res_right}
				mutex.unlock()

func _process(_delta):
	camera_fps = Engine.get_frames_per_second()
	
	is_debug_visible = debug_view.visible
	
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
	var results = null
	mutex.lock()
	results = result_mediapipe
	result_mediapipe = null
	mutex.unlock()
	
	if results:
		hand_data = []
		last_body_detected_time = Time.get_ticks_msec() / 1000.0
		
		# Traitement GAUCHE (Joueur 1)
		if results.left and results.left.pose_landmarks.size() > 0:
			_process_half_body(results.left.pose_landmarks[0], 1)
			
		# Traitement DROIT (Joueur 2)
		if results.right and results.right.pose_landmarks.size() > 0:
			_process_half_body(results.right.pose_landmarks[0], 2)

func _process_half_body(pose_landmarks, player_index: int):
	var lm = pose_landmarks.landmarks
	
	# Fonction pour corriger le X
	# Si c'est le côté droit, le X global = (X_local / 2) + 0.5
	# Si c'est le côté gauche, le X global = (X_local / 2)
	# Calcul des vecteurs (on utilise le fix_x pour les coordonnées)
	var wrist_r := Vector3(lm[15].x, lm[15].y, lm[15].z)
	var elbow_r := Vector3(lm[13].x, lm[13].y, lm[13].z)
	var dir_r   := (wrist_r - elbow_r).normalized()
	
	var wrist_l := Vector3(lm[16].x, lm[16].y, lm[16].z)
	var elbow_l := Vector3(lm[14].x, lm[14].y, lm[14].z)
	var dir_l   := (wrist_l - elbow_l).normalized()

	# Ajout à hand_data
	hand_data.append({
		"x": lm[16].x, 
		"y": lm[16].y,
		"handedness": "Left", 
		"index": player_index, 
		"angle_x": atan2(dir_l.y, dir_l.z),
		"angle_z": atan2(dir_l.y, dir_l.x) 
	})
	hand_data.append({
		"x": lm[15].x, 
		"y": lm[15].y,
		"handedness": "Right", 
		"index": player_index, 
		"angle_x": atan2(dir_r.y, dir_r.z),
		"angle_z": atan2(dir_r.y, dir_r.x)
	})

func _exit_tree() -> void:
	runThread = false
	if thread_mp:
		thread_mp.wait_to_finish()
