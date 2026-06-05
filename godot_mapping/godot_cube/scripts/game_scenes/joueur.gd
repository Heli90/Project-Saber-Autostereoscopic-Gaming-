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
	if player_id == 2: apply_blue_shader()
		
func apply_blue_shader():
	if blue_shader_material:
		# On applique l'override sur la surface 0 (l'index par défaut des formes)
		left_saber_mesh.set_surface_override_material(0, blue_shader_material)
		right_saber_mesh.set_surface_override_material(0, blue_shader_material)

func collision(body: Node3D) -> void:
	if body.is_in_group("cube"): body.collision()

func dilatate_y(f : float) -> float :
	return 0.509259*f*f -0.52778*f
	
func dilatate_x(f : float) -> float :
	if f > 0 :
		return 0.4*f*f
	else :
		return -0.4*f*f

func _physics_process(_delta: float) -> void:
	if not landmarks or landmarks.hand_data.is_empty(): return
	for data in landmarks.hand_data:
		if data["index"] == player_id :
			var saber : Area3D = left_saber if data["handedness"] == "Left" else right_saber
			
			# Recalibrage des sabres dans la zone de chaque joueur
			var local_x : float
			if player_id == 1: local_x = data["x"] / 0.5
			else: local_x = (data["x"] - 0.5) / 0.5
			var local_y = data["y"]      
			
			var pos_x : float = lerp(-saber_range_x, saber_range_x, local_x)
			var pos_y : float = lerp(saber_y_max, saber_y_min, local_y)
			pos_x = dilatate_x(pos_x)
			pos_y = dilatate_y(pos_y)
			saber.position.x = pos_x
			saber.position.y = pos_y
			# Rotation du sabre selon l'axe de l'avant-bras
			saber.rotation.z = atan2(0,-1)/2 - data["angle_z"]
			if data["handedness"] == "Right" :
				if player_id == 1 :
					j1_label.text = "x = %.2f, y = %.2f, angle = %.2f" % [pos_x, pos_y,atan2(0,-1)/2 - data["angle_z"]]
				elif player_id == 2:
					j2_label.text = "x = %.2f, y = %.2f, angle = %.2f" % [pos_x, pos_y,atan2(0,-1)/2 - data["angle_z"]]
			#if data["handedness"]=="Right":
			#	saber.rotation.x = data["angle_x"]
			#else :
			#	saber.rotation.x = -data["angle_x"]
