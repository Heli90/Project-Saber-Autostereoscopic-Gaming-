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
var ampl_z = [2.0,2.0]
var base_pos_z = [-2.0,-2.0]

# Facteur d'amplification des mouvements vers les bords extrémaux
var alpha1 : float
var alpha2 : float
var midx1 : float
var midx2 : float
var beta1 : float
var beta2 : float
var midy1 : float
var midy2 : float
var c1_1_x : float
var c2_1_x : float
var c1_2_x : float
var c2_2_x : float
var c1_1_y : float
var c2_1_y : float
var c1_2_y : float
var c2_2_y : float


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Initialisation des marqueurs de corps
	landmarks = get_node_or_null("../../../../Game/LandMarksProceed")
	j1_label = get_node_or_null("../../../../Game/J1Label")
	j2_label = get_node_or_null("../../../../Game/J2Label")
	
	#Initilisation de scoefficients de dilatations
	alpha1 = Global.alpha1
	alpha2 = Global.alpha2
	beta1 = Global.beta1
	beta2 = Global.beta2
	midx1 = Global.midx1
	midx2 = Global.midx2
	midy1 = Global.midy1
	midy2 = Global.midy2
	var tx1 = alpha_mid_to_c1_c2(alpha1,midx1)
	c1_1_x = tx1[0]
	c2_1_x = tx1[1]
	var tx2 = alpha_mid_to_c1_c2(alpha2,midx2)
	c1_2_x = tx2[0]
	c2_2_x = tx2[1]
	var ty1 = alpha_mid_to_c1_c2(beta1,midy1)
	c1_1_y = ty1[0]
	c2_1_y = ty1[1]
	var ty2 = alpha_mid_to_c1_c2(beta2,midy2)
	c1_2_y = ty2[0]
	c2_2_y = ty2[1]
	base_pos_z[0]=Global.base_depth_j1
	base_pos_z[1]=Global.base_depth_j2
	ampl_z[0] = Global.ampl_z_j1
	ampl_z[1] = Global.ampl_z_j2
	
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

func alpha_mid_to_c1_c2(alpha : float, mid : float):
	var c1 = 0.5*pow(1.0-mid, -1.0/alpha)
	var c2 = 0.5*pow(mid, -1.0/alpha)
	return [c1,c2]

func transform_data(f : float, alpha : float, mid : float, c1 : float, c2 : float) -> float :
	f = clampf(f,0.0,1.0)
	if f < mid :
		return 0.5 - c2*pow(mid-f,1.0/alpha)
	else :
		return 0.5 + c1*pow(f-mid,1.0/alpha)

func _physics_process(_delta: float) -> void:
	if not landmarks or landmarks.hand_data.is_empty(): return
	
	# Mise à jour du facteur d'amplication des mouvements
	if alpha1 != Global.alpha1:
		alpha1 = Global.alpha1
		var tx1 = alpha_mid_to_c1_c2(alpha1,midx1)
		c1_1_x = tx1[0]
		c2_1_x = tx1[1]
	if alpha2 != Global.alpha2:
		alpha2 = Global.alpha2
		var tx2 = alpha_mid_to_c1_c2(alpha2,midx2)
		c1_2_x = tx2[0]
		c2_2_x = tx2[1]
	if beta1 != Global.beta1: 
		beta1 = Global.beta1
		var ty1 = alpha_mid_to_c1_c2(beta1,midy1)
		c1_1_y = ty1[0]
		c2_1_y = ty1[1]
	if beta2 != Global.beta2: 
		beta2 = Global.beta2
		var ty2 = alpha_mid_to_c1_c2(beta2,midy2)
		c1_2_y = ty2[0]
		c2_2_y = ty2[1]
	if midx1 != Global.midx1: 
		midx1 = Global.midx1
		var tx1 = alpha_mid_to_c1_c2(alpha1,midx1)
		c1_1_x = tx1[0]
		c2_1_x = tx1[1]
	if midx2 != Global.midx2:
		midx2 = Global.midx2
		var tx2 = alpha_mid_to_c1_c2(alpha2,midx2)
		c1_2_x = tx2[0]
		c2_2_x = tx2[1]
	if midy1 != Global.midy1:
		midy1 = Global.midy1
		var ty1 = alpha_mid_to_c1_c2(beta1,midy1)
		c1_1_y = ty1[0]
		c2_1_y = ty1[1]
	if midy2 != Global.midy2:
		midy2 = Global.midy2
		var ty2 = alpha_mid_to_c1_c2(beta2,midy2)
		c1_2_y = ty2[0]
		c2_2_y = ty2[1]
	if ampl_z[0] != Global.ampl_z_j1 :
		ampl_z[0] = Global.ampl_z_j1
	if ampl_z[1] != Global.ampl_z_j2 :
		ampl_z[1] = Global.ampl_z_j2
	if base_pos_z[0] != Global.base_depth_j1 :
		base_pos_z[0] = Global.base_depth_j1
	if base_pos_z[1] != Global.base_depth_j2:
		base_pos_z[1] = Global.base_depth_j2
	
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
				local_x = transform_data(data["x"],alpha1,midx1,c1_1_x,c2_1_x)
				local_y = transform_data(data["y"], beta1, midy1,c1_1_y,c2_1_y)
			else :
				local_x = transform_data(data["x"],alpha2,midx2,c1_2_x,c2_2_x)
				local_y = transform_data(data["y"], beta2, midy2,c1_2_y,c2_2_y)
			
			var pos_x : float = lerp(-saber_range_x, saber_range_x, local_x)
			var pos_y : float = lerp(saber_y_max, saber_y_min, local_y)
			var pos_z : float = base_pos_z[player_id-1]+ampl_z[player_id-1]*data["z"]
			var rot_z : float = -atan2(0, -1) / 2.0 - data["angle_z"]
			
			# On ignore les frames problématiques
			if not is_finite(pos_x) or not is_finite(pos_y) or not is_finite(rot_z) or not is_finite(pos_z): continue
			
			saber.position.x = pos_x
			saber.position.y = pos_y
			
			if Global.using_depth :
				saber.position.z = pos_z
			else :
				saber.position.z = base_pos_z[player_id-1]
				
			if player_id == 1:
				if data["handedness"] == "Left" :
					Global.bonus_z_j1_l = -10*(saber.position.z - base_pos_z[player_id-1])
				else :
					Global.bonus_z_j1_r = -10*(saber.position.z - base_pos_z[player_id-1])
			if player_id == 2 :
				if data["handedness"] == "Left" :
					Global.bonus_z_j2_l = -10*(saber.position.z - base_pos_z[player_id-1])
				else :
					Global.bonus_z_j2_r = -10*(saber.position.z - base_pos_z[player_id-1])
					
			saber.rotation.z = rot_z
			
			#print("alpha1 = %f, midx1 = %f, beta1 = %f, midy1 = %f\n alpha2 = %f, midx2 = %f, beta2 = %f, midy2 = %f"%[alpha1,midx1,beta1,midy1,alpha2,midx2,beta2,midy2])
			
			# Affichage des labels
			if data["handedness"] == "Right" :
				if player_id == 1 and j1_label:
					j1_label.text = "x = %.2f, y = %.2f, z=%.2f, angle = %.2f\n" % [pos_x, pos_y, pos_z, rot_z]
				elif player_id == 2 and j2_label:
					j2_label.text = "x = %.2f, y = %.2f, z=%.2f, angle = %.2f\n " % [pos_x, pos_y, pos_z, rot_z]
