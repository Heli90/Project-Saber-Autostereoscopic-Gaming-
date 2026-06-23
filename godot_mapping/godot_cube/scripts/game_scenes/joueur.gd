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

# Facteur d'amplification des mouvements vers les bords extrémaux
var alpha1 : float = 2.0
var alpha2 : float = 2.0
var midx1 : float = 0.5
var midx2 : float = 0.5
var beta1 : float = 3.0
var beta2 : float = 3.0
var midy1 : float = 0.3
var midy2 : float = 0.3


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Initialisation des marqueurs de corps
	landmarks = get_node_or_null("../../../../Game/LandMarksProceed")
	j1_label = get_node_or_null("../../../../Game/J1Label")
	j2_label = get_node_or_null("../../../../Game/J2Label")
	alpha1 = Global.alpha1
	alpha2 = Global.alpha2
	beta1 = Global.beta1
	beta2 = Global.beta2
	midx1 = Global.midx1
	midx2 = Global.midx2
	midy1 = Global.midy1
	midy2 = Global.midy2
	
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

func transform_data(f : float, alpha : float, mid : float) -> float :
	f = clampf(f,0.0,1.0)
	var c1 = 0.5*pow(1.0-mid, -1.0/alpha)
	var c2 = 0.5*pow(mid, -1.0/alpha)
	if f < mid :
		return 0.5 - c2*pow(mid-f,1.0/alpha)
	else :
		return 0.5 + c1*pow(f-mid,1.0/alpha)

func _physics_process(_delta: float) -> void:
	if not landmarks or landmarks.hand_data.is_empty(): return
	
	# Mise à jour du facteur d'amplication des mouvements
	if alpha1 != Global.alpha1: alpha1 = Global.alpha1
	if alpha2 != Global.alpha2: alpha2 = Global.alpha2
	if beta1 != Global.beta1: beta1 = Global.beta1
	if beta2 != Global.beta2: beta2 = Global.beta2
	if midx1 != Global.midx1: midx1 = Global.midx1
	if midx2 != Global.midx2: midx2 = Global.midx2
	if midy1 != Global.midy1: midy1 = Global.midy1
	if midy2 != Global.midy2: midy2 = Global.midy2
	
	for data in landmarks.hand_data:
		if data["index"] == player_id :
			# On s'assure que les données MediaPipe sont valides
			if data["x"] == null or data["y"] == null or data["angle_z"] == null:
				continue
			
			# On récupère le bon sabre (droite ou gauche) sur lequel on applique les modifications de positions
			var saber : Area3D = left_saber if data["handedness"] == "Left" else right_saber
			
			var local_x : float = 0.0
			var local_y : float = 0.0
			if player_id == 1:
				local_x = transform_data(data["x"],alpha1,midx1)
				local_y = transform_data(data["y"], beta1, midy1)
			else :
				local_x = transform_data(data["x"],alpha2,midx2)
				local_y = transform_data(data["y"], beta2, midy2)
			
			var pos_x : float = lerp(-saber_range_x, saber_range_x, local_x)
			var pos_y : float = lerp(saber_y_max, saber_y_min, local_y)
			var rot_z : float = -atan2(0, -1) / 2.0 - data["angle_z"]
			
			# On ignore les frames problématiques
			if not is_finite(pos_x) or not is_finite(pos_y) or not is_finite(rot_z): continue
			
			saber.position.x = pos_x
			saber.position.y = pos_y
			saber.rotation.z = rot_z
			
			#print("alpha1 = %f, midx1 = %f, beta1 = %f, midy1 = %f\n alpha2 = %f, midx2 = %f, beta2 = %f, midy2 = %f"%[alpha1,midx1,beta1,midy1,alpha2,midx2,beta2,midy2])
			
			# Affichage des labels
			if data["handedness"] == "Right" :
				if player_id == 1 and j1_label:
					j1_label.text = "x = %.2f, y = %.2f, angle = %.2f\n" % [pos_x, data["y"], rot_z]
				elif player_id == 2 and j2_label:
					j2_label.text = "x = %.2f, y = %.2f, angle = %.2f\n " % [pos_x, data["y"], rot_z]
