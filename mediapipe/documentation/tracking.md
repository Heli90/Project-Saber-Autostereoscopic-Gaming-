# Comment utiliser l'API MediaPipe dans Godot

## Projet GDMP-demo

Le projet GDMP-demo permet de pouvoir tester les différentes fonctionnalités de l'API MediaPipe dans Godot. Son fonctionnement est sensiblement similaire à celui disponible sur navigateur : https://mediapipe-studio.webapps.google.com/studio/demo/hand_landmarker

On va s'inspirer de ce projet demo pour notre propre projet.

## Hand landmarkers

### Documentation

Voici la description générale du fonctionnement de MediaPipeHands : https://mediapipe.readthedocs.io/en/latest/solutions/hands.html

![alt text](hand_landmarks_numerotation.png)

N.B : Ce site ne documente que des utilisations dans Python, JavaScript, etc.. Pour une utilisation explicite dans Godot, voir

### Scène Godot pour afficher les marqueurs sur les mains

Pour réaliser un scène avec une fenêtre qui affiche la caméra et des traqueurs sur nos mains, ainsi que les coordonnées des noeuds dans le terminal, on peut faire la scène suivante :

    Node_3d (script attaché : hand_tracking_display.gd)

    ├── SubViewPortContainer

    │   ├── SubViewport

    │       ├── TextureReact

    ├── CanvasLayer

    │   ├── DebugOverlay

Pour ce qui est des script, on va reprendre les scripts `LandMarksRender.gd` et `HandRenderer.gd`, qui servent à traduire les données MediaPipe en données intelligible sur Godot (comme une image). On utilise également hand_landmarker.task pour mettre des traqueurs sur les mains.

### Utilisation de hand_landmarker.task

- On crée un nouveau hand_landmarker *task* en faisant *task = MediaPipeHandLandMarker.new()*

- *task.initialize(options,running_mode,num_hands)* permet d'initialiser le nouveau hand_landmarker. 
  - Par défaut, on prend *options = MediaPipeTaskBaseOptions.new()*. 
  - *running_mode* attend un entier, qui décrit quel est le type d'objet que MediaPipe va devoir analyser (ex : 0 = Mode Image, 1 = Mode Vidéo)
  - *num_hands* donne le nombre de mains à analyser

- Pour convertir une image *img* de la camera au format MediaPipe, on écrit :    *var mp_image = MediaPipeImage.new(); mp_image.set_image(img)*
- Pour l'analyser ensuite, on peut écrire : *var result = task.detect(mp_image)*
- Finalement, pour obtenir l'image contenant les marqueurs associés à cette analyse, on peut écrire : *var output = renderer.render(mp_image, result.hand_landmarks); debug_view.texture = ImageTexture.create_from_image(output.image)*

### Script de test

On peut alors écrire un tel script :

```gdscript
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
```

## Pose landmarkers

Voici la description générale du fonctionnement de MediaPipePoseLandmarks : https://developers.google.com/edge/mediapipe/solutions/vision/pose_landmarker

![alt text](pose_landmarks_index.png)

On peut réutiliser la même scène que pour les mains, la logique générale reste la même.

### Utilisation de pose_landmarker_full

- La seule différence se fait dans les paramètres pris par notre objet *task* : 
  
  *task.initialize(options, running_mode, num_pose)*

	*Num_pose* désigne le nombre de corps pouvant être capturés


### Script de test

On peut alors implémenter un tel script pour afficher certaines données à l'écran (en veillant d'ajouter les labels et le sélecteurs de caméra):

```gdscript
extends Node3D

# Variables MediaPipe
var task
var renderer
var model_path = "res://pose_landmarker/pose_landmarker_full.task"
var delegate := MediaPipeTaskBaseOptions.DELEGATE_CPU

var running_mode = MediaPipeVisionTask.RUNNING_MODE_IMAGE
var num_pose = 4

# Variables Caméra
var camera_extension: CameraServerExtension
var camera_feed: CameraFeed

@onready var viewport = $SubViewportContainer/CameraViewport
@onready var texture_rect = $SubViewportContainer/CameraViewport/TestAffichage
@onready var debug_view = $CanvasLayer/DebugOverlay # Un TextureRect pour voir le résultat
@onready var num_label : Label = $CanvasLayerLabel/NumLabel
@onready var camera_fps_label : Label = $CanvasLayerLabel/CameraFPSLabel
@onready var detection_label : Label = $CanvasLayerLabel/DetectionLabel
@onready var render_label: Label = $CanvasLayerLabel/RenderLabel
@onready var display_label : Label = $CanvasLayerLabel/DisplayLabel
@onready var coordinates_display: Label = $CanvasLayerLabel/CoordinatesDisplay
@onready var gesture_label: Label = $CanvasLayerLabel/GestureLabel
@onready var confirmation_dialog: ConfirmationDialog = $SelectCamera
@onready var selected_feed: OptionButton = $SelectCamera/VBoxContainer/HBoxContainer/SelectedFeed
@onready var selected_format: OptionButton = $SelectCamera/VBoxContainer/SelectedFormat

func _ready():
	_setup_mediapipe()
	_setup_camera_selection()
	_setup_camera_permissions()

func _setup_mediapipe():
	if not FileAccess.file_exists(model_path):
		print("ERREUR : Modèle .task introuvable !")
		return
	var buffer = FileAccess.get_file_as_bytes(model_path)
	var options = MediaPipeTaskBaseOptions.new()
	options.delegate = delegate
	options.model_asset_buffer = buffer
	task = MediaPipePoseLandmarker.new()
	task.initialize(options, running_mode, num_pose)
	renderer = MediaPipePoseRenderer.new()
	print("MediaPipe initialisé.")

func _setup_camera_selection():
	# Configuration du dialogue
	confirmation_dialog.get_ok_button().disabled = true
	selected_feed.item_selected.connect(self._on_camera_selected)
	selected_format.item_selected.connect(self._on_format_selected)
	confirmation_dialog.confirmed.connect(self._start_camera)
	
	# Signal système pour détecter les changements de caméras
	CameraServer.camera_feeds_updated.connect(self._update_camera_list)

func _update_camera_list():
	selected_feed.clear()
	var feeds = CameraServer.feeds()
	
	if feeds.size() == 0:
		selected_feed.add_item("Aucune caméra trouvée")
		selected_feed.disabled = true
	else:
		selected_feed.disabled = false
		for feed in feeds:
			selected_feed.add_item(feed.get_name(), feed.get_id())
			print(selected_feed.get_item_text(0))
	
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
			_open_camera_selection()
	else:
		_open_camera_selection()

func _on_permission(granted: bool):
	if granted: _open_camera_selection()

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
	if camera_feed == null: return
	
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
	if Input.is_action_just_pressed("quitter"):
		confirmation_dialog.get_ok_button().disabled = true
		_setup_camera_permissions()
		_open_camera_selection()
		camera_feed.feed_is_active = false

func update_debug_overlay(image: Image) -> void:
	image.convert(Image.FORMAT_RGB8)
	if debug_view.texture == null :
		debug_view.texture = ImageTexture.create_from_image(image)
	else :
		if Vector2i(debug_view.texture.get_size()) == image.get_size():
			debug_view.texture.update(image)
		else:
			debug_view.texture.set_image(image)

func _on_body_data_received(pose_landmarks, pose_index):
	# Tout ce qui concerne la gestion des données relatives aux mains se fait ici
	coordinates_display.text = "Coordonnées: x=%.3f,\n y=%.3f,\n z=%.3f\n Index : %d" % [
	pose_landmarks.landmarks[15].x,
	pose_landmarks.landmarks[15].y,
	pose_landmarks.landmarks[15].z, pose_index]


func _process(_delta):
	reload_camera_selection()
	var current_fps = Engine.get_frames_per_second()
	camera_fps_label.text = "Camera FPS : %d fps" % [current_fps]
	
	num_label.text = "Marqueurs : 0"
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
	var time_detect = (Time.get_ticks_usec()-start_detect)/1000.0
	detection_label.text = "MediaPipe task Time : %.2f ms" % [time_detect]
	
	if result:
		# Dessin des marqueurs sur les mains
		var start_render = Time.get_ticks_usec()
		var output = renderer.render(mp_image, result.pose_landmarks)
		var time_render = (Time.get_ticks_usec()-start_render)/1000.0
		render_label.text = "MediaPipe Render Time : %.2f ms" % [time_render]
		
		var start_display = Time.get_ticks_usec()
		update_debug_overlay(output.image)
		var time_display = (Time.get_ticks_usec()-start_display)/1000.0
		display_label.text = "Display Time : %.2f ms" % [time_display]
		
		# Traitement des mains détectés
		var size = result.pose_landmarks.size()
		for i in range(size):
			num_label.text = "Marqueurs : %d" % [size]
			var pose_landmarks = result.pose_landmarks[i]
			_on_body_data_received(pose_landmarks, i) 
```