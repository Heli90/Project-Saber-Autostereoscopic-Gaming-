extends Node3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
@export var player_id = 1
@onready var camera_fps: Camera3D = $CameraControllerFPS/Camera
@onready var camera_controller_fps: Node3D = $CameraControllerFPS
@onready var left_saber : Area3D = $LeftSaber
@onready var right_saber : Area3D = $RightSaber

var landmarks: Node2D

const SABRE_X_RANGE : float = 1.2
const SABRE_Y_MIN   : float = 0.4
const SABRE_Y_MAX   : float = 1.6

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# On initialise les marqueurs de corps
	landmarks = get_node_or_null("../../../../CubeTournant/LandMarksProceed")
	if not landmarks:
		landmarks = get_node_or_null("../CubeTournant/LandMarksProceed")
	# On initialise un signal à chaque fois que le sabre traverse un cube
	left_saber.body_entered.connect(collision)
	right_saber.body_entered.connect(collision)

func collision(body: Node3D) -> void:
	if body.is_in_group("cube"): body.collision()

func _physics_process(_delta: float) -> void:
	if not landmarks or landmarks.hand_data.is_empty(): return
	for data in landmarks.hand_data:
		var sabre : Area3D = left_saber if data["handedness"] == "Left" else right_saber
		# Exemple de coordonnées pour tester (A CHANGER !!!)
		var mapped_x : float = lerp(-SABRE_X_RANGE, SABRE_X_RANGE, data["x"])
		var mapped_y : float = lerp(SABRE_Y_MAX, SABRE_Y_MIN, data["y"])
		sabre.position.x = mapped_x
		sabre.position.y = mapped_y
		# Rotation du sabre selon l'axe de l'avant-bras
		sabre.rotation.z = atan2(0,-1)/2 - data["angle_z"]
