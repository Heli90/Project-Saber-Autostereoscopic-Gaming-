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
var d1_x : float
var d2_x : float
var d1_y : float
var d2_y : float
var max_x_1 : float = 0.5
var max_y_1 : float = 0.5
var max_x_2 : float = 0.5
var max_y_2 : float = 0.5

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
	d1_x = Global.d1_x
	d1_y = Global.d1_y
	d2_x = Global.d2_x
	d2_x = Global.d2_x
	if player_id == 2: apply_blue_shader()
		
func apply_blue_shader():
	if blue_shader_material:
		# On applique l'override sur la surface 0 (l'index par défaut des formes)
		left_saber_mesh.set_surface_override_material(0, blue_shader_material)
		right_saber_mesh.set_surface_override_material(0, blue_shader_material)

func collision(body: Node3D) -> void:
	if body.is_in_group("cube"): body.collision()

func transform_data_x(f : float) -> float :
	if f < 0.5 :
		return 0.5 - sqrt(0.5)*sqrt(0.5-f)
	else :
		return 0.5 + sqrt(0.5)*sqrt(f-0.5)
		
func transform_data_y(f :float) -> float :
	return sqrt(f)

func dilatate_y(f : float) -> float :
	var s = f
	if player_id == 1:
		s = d1_y * (f-1.5) + 1.5
	else :
		s = d2_y * (f-1.5) + 1.5
	if s >= saber_y_max :
		return saber_y_max
	if s<=saber_y_min :
		return saber_y_min
	return s
	
func dilatate_x(f : float) -> float :
	var s = f
	if player_id == 1:
		s = d1_x * f
	else :
		s = d2_x * f
	if s >= saber_range_x :
		return saber_range_x
	if s<=-saber_range_x :
		return -saber_range_x
	return s

func _physics_process(_delta: float) -> void:
	if not landmarks or landmarks.hand_data.is_empty(): return
	for data in landmarks.hand_data:
		if data["index"] == player_id :
			var saber : Area3D = left_saber if data["handedness"] == "Left" else right_saber
			
			# Recalibrage des sabres dans la zone de chaque joueur
			
			var local_x = transform_data_x(data["x"])
			var local_y = transform_data_y(data["y"])      
			
			var pos_x : float = lerp(-saber_range_x, saber_range_x, local_x)
			var pos_y : float = lerp(saber_y_max, saber_y_min, local_y)
			if Global.launched_mode <= 1 :
				if player_id == 1 :
					if pos_x > max_x_1 and pos_x < 1 :
						max_x_1 = (pos_x+max_x_1)/2
						var d =  saber_range_x/max_x_1 
						if d < d1_x and d >= 1:
							Global.d1_x = d
							d1_x = d
					if pos_y > max_y_1 and pos_y < 1 :
						max_y_1 = (pos_y+max_y_1)/2
						var d =  saber_range_x/max_y_1
						if d < d1_y and d >= 1:
							Global.d1_y = d
							d1_y = d
				else :
					if pos_x > max_x_2 and pos_x < 1:
						max_x_2 = (pos_x+max_x_2)/2
						var d = saber_range_x/max_x_2
						if d < d2_x and d >= 1 :
							Global.d2_x = d
							d2_x = d
					if pos_y > max_y_2 and pos_y < 1:
						max_y_2 = (pos_y+max_y_2)/2
						var d = saber_range_x/max_y_2
						if d < d2_y and d >= 1 :
							Global.d2_y =d
							d2_y = d
			
			
							
			saber.position.x = dilatate_x(pos_x)
			saber.position.y = dilatate_y(pos_y)
			
			# Rotation du sabre selon l'axe de l'avant-bras
			saber.rotation.z = -atan2(0,-1)/2 - data["angle_z"]
			if data["handedness"] == "Right" :
				if player_id == 1 :
					j1_label.text = "x = %.2f, y = %.2f, angle = %.2f\n Max x : %.2f, y : %.2f, Dilatation x : %.2f, y : %.2f" % [local_x, local_y,-atan2(0,-1)/2 - data["angle_z"], max_x_1,max_y_1,d1_x,d1_y]
				elif player_id == 2:
					j2_label.text = "x = %.2f, y = %.2f, angle = %.2f\n Max x : %.2f, y : %.2f, Dilatation x : %.2f, y : %.2f" % [local_x, local_y,-atan2(0,-1)/2 - data["angle_z"],max_x_2, max_y_2,d2_x,d2_y]
			#if data["handedness"]=="Right":
			#	saber.rotation.x = data["angle_x"]
			#else :
			#	saber.rotation.x = -data["angle_x"]
