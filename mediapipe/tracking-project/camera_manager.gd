extends Node3D  # On change Node en Control pour correspondre à la démo

var camera_extension: CameraServerExtension
var camera_feed

# Références vers l'extension de gestion des permissions et le flux vidéo sélectionné
#@onready var display = $SubViewportContainer/CameraViewport/CameraTextureRect # Adapte le chemin

func _ready():
	# 1. Initialisation de l'extension caméra
	if OS.get_name() in ["Windows", "iOS"]:
		camera_extension = CameraServerExtension.new()
		camera_extension.permission_result.connect(self._on_camera_permission_result)
		
		if not camera_extension.permission_granted():
			print("Demande de permission caméra...")
			camera_extension.request_permission()
		else:
			_initialize_camera()
	else:
		_initialize_camera()

func _on_camera_permission_result(granted: bool):
	if granted:
		print("Permission accordée !")
		_initialize_camera()
	else:
		print("Permission refusée par l'utilisateur.")

# Recherche d'une caméra disponible et configuration de son affichage
# Démarrage de la caméra
# Attente courte afin de laisser le temps au système de détecter les périphériques vidéo
func _initialize_camera():
	await get_tree().create_timer(0.5).timeout  
	CameraServer.monitoring_feeds = true
	var feeds = CameraServer.feeds()
	
	if feeds.size() > 0:
		camera_feed = feeds[0]
		camera_feed.feed_is_active = true
		
		# On crée la texture
		var tex = CameraTexture.new()
		tex.camera_feed_id = camera_feed.get_id()
		tex.which_feed = CameraServer.FEED_RGBA_IMAGE
		
		# On l'assigne DIRECTEMENT au nœud
		# (Vérifie bien le chemin vers ton TextureRect ici)
		get_node("SubViewportContainer/CameraViewport/TestAffichage").texture = tex
		
		print("Tentative d'affichage direct réussie sur le nœud TestAffichage")
	else:
		print("ÉCHEC : Aucune caméra trouvée.")
