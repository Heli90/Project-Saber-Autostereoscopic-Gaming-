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
- Finalemnt, pour obtenir l'image contenant les marqueurs associés à cette analyse, on peut écrire : *var output = renderer.render(mp_image, result.hand_landmarks); debug_view.texture = ImageTexture.create_from_image(output.image)*

### Script de test

On peut alors écrire un tel script pour afficher les marqueurs ainsi que le nombre de mains détectées:

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
@export var label: Label

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
	task.initialize(options, 1,4,0.07,0.07,0.07)
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
	print("Coordonnées: x=%f, y=%f, z=%f" % [
	hand_landmarks.landmarks[8].x,
	hand_landmarks.landmarks[8].y,
	hand_landmarks.landmarks[8].z])
	print("Main", hand_index)


func _process(_delta):
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
	var result = task.detect(mp_image)
	
	if result:
		# Dessin des marqueurs sur les mains
		var output = renderer.render(mp_image, result.hand_landmarks)
		update_debug_overlay(output.image)
		
		# Traitement des mains détectés
		var size = result.hand_landmarks.size()
		for i in range(size):
			label.text = "%d" % [size]
			var hand_landmarks = result.hand_landmarks[i]
			_on_hand_data_received(hand_landmarks, i) # On passe l'index de la main (0 ou 1)

```