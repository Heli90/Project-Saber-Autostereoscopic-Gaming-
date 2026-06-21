extends Node3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
@export var player_id = 1
@onready var camera_fps: Camera3D = $CameraController/Camera
@onready var camera_controller_fps: Node3D = $CameraController
@onready var left_saber : Area3D = $LeftSaber
@onready var right_saber : Area3D = $RightSaber
@onready var left_saber_mesh : MeshInstance3D = $LeftSaber/MeshInstance3D
@onready var right_saber_mesh : MeshInstance3D = $RightSaber/MeshInstance3D
@export var blue_shader_material : ShaderMaterial
@onready var j1_label: Label
@onready var j2_label: Label

var landmarks: Node2D
var saber_range_x : float = 2.5
var saber_y_min : float = 0.0
var saber_y_max : float = 3.0
var alpha : float = 2.0 # Quantifie le degré de transformation des données. Plus alpha est grand, plus on étire les données vers leurs valeurs extrémales.

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# On initialise les marqueurs de corps
	landmarks = get_node_or_null("../../../../Game/LandMarksProceed")
	j1_label = get_node_or_null("../../../../Game/J1Label")
	j2_label = get_node_or_null("../../../../Game/J2Label")
	if not landmarks:
		landmarks = get_node("../Game/LandMarksProceed")
		j1_label = get_node("../Game/J1Label")
		j2_label = get_node("../Game/J2Label")
	# On initialise un signal à chaque fois que le sabre traverse un cube
	left_saber.body_entered.connect(collision)
	right_saber.body_entered.connect(collision)
	# On récupère les amplitudes globales des bras de chaque joueur
	if player_id == 2: apply_blue_shader()
		
func apply_blue_shader():
	if blue_shader_material:
		# On applique l'override sur la surface 0 (l'index par défaut des formes)
		left_saber_mesh.set_surface_override_material(0, blue_shader_material)
		right_saber_mesh.set_surface_override_material(0, blue_shader_material)

func collision(body: Node3D) -> void:
	if body.is_in_group("cube"): body.collision()

func transform_data_x(f : float) -> float :
	f = clampf(f,0.0,1.0)
	if f < 0.5 :
		return 0.5 - pow(0.5,1.0-1.0/alpha)*pow(0.5-f,1.0/alpha)
	else :
		return 0.5 + pow(0.5,1.0-1.0/alpha)*pow(f-0.5,1.0/alpha)
		
func transform_data_y(f :float) -> float :
	return sqrt(f)

func _physics_process(_delta: float) -> void:
	if not landmarks or landmarks.hand_data.is_empty(): return
	
	for data in landmarks.hand_data:
		if data["index"] == player_id :
			# Vérification de sécurité essentielle : on s'assure que les données MediaPipe sont valides
			if data["x"] == null or data["y"] == null or data["angle_z"] == null:
				continue
				
			var saber : Area3D = left_saber if data["handedness"] == "Left" else right_saber
			
			# On crée des variables locales bien définies à chaque passage
			var local_x : float = transform_data_x(data["x"])
			var local_y : float = transform_data_y(data["y"])
							
			var pos_x : float = lerp(-saber_range_x, saber_range_x, local_x)
			var pos_y : float = lerp(saber_y_max, saber_y_min, local_y)
			var rot_z : float = -atan2(0, -1) / 2.0 - data["angle_z"]
			
			# ULTIME SÉCURITÉ : Si un NaN a réussi à s'infiltrer, on ignore cette frame pour ce sabre
			if not is_finite(pos_x) or not is_finite(pos_y) or not is_finite(rot_z):
				continue
			
			# Application des transformations sécurisées
			saber.position.x = pos_x
			saber.position.y = pos_y
			saber.rotation.z = rot_z
			
			# Affichage des labels
			if data["handedness"] == "Right" :
				if player_id == 1 and j1_label:
					j1_label.text = "x = %.2f, y = %.2f, angle = %.2f\n" % [pos_x, pos_y, rot_z]
				elif player_id == 2 and j2_label:
					j2_label.text = "x = %.2f, y = %.2f, angle = %.2f\n " % [pos_x, pos_y, rot_z]
