extends CharacterBody3D

const SPEED: float = 5.0
const JUMP_VELOCITY: float = 4.5
@export var player_id = 1
@onready var camera_fps: Camera3D = $CameraControllerFPS/Camera
@onready var camera_controller_fps: Node3D = $CameraControllerFPS
@onready var forme: MeshInstance3D = $Forme

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# Chute automatique du joueur par la gravité par défaut.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Saut manuel du joueur.
	if Input.is_action_just_pressed("SautJ%s"%player_id) and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Reçoit la direction et gère le mouvement et l'accélération.
	var input_dir = Input.get_vector("GaucheJ%s"%player_id, "DroiteJ%s"%player_id, "AvancerJ%s"%player_id, "ReculerJ%s"%player_id)
	var direction = (camera_controller_fps.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# Gère la rotation du modèle 3D.
	if input_dir != Vector2(0,0):
		forme.rotation_degrees.y = camera_controller_fps.rotation_degrees.y - rad_to_deg(input_dir.angle()) - 90
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
