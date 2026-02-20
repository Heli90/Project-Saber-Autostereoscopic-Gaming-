extends CharacterBody3D

const player_speed = 5.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("Gauche", "Droite", "Avancer", "Reculer")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * player_speed
		velocity.z = direction.z * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)
		velocity.z = move_toward(velocity.z, 0, player_speed)

	# Application de la vélocité et gestion des collisions
	move_and_slide()

@onready var epaule_right = $Epaule_Right
@onready var epaule_left = $Epaule_Left

func _input(event):
	if event.is_action_pressed("Contrôle du bras droit"):
		lever_bras_droit()
	elif event.is_action_pressed("Contrôle du bras gauche"):
		lever_bras_gauche()
	elif event.is_action_released("Contrôle du bras droit"):
		baisser_bras_droit()
	elif event.is_action_released("Contrôle du bras gauche"):
		baisser_bras_gauche()
		
func lever_bras_gauche():
	var bras_gauche = create_tween()
	# On fait tourner l'épaule de 90 degrés (1.5 radians environ) en 0.2 secondes
	bras_gauche.tween_property(epaule_left, "rotation:x", deg_to_rad(-90), 0.2)

func baisser_bras_gauche():
	var bras_gauche = create_tween()
	bras_gauche.tween_property(epaule_left, "rotation:x", 0, 0.2)

func lever_bras_droit():
	var bras_droit = create_tween()
	# On fait tourner l'épaule de 90 degrés (1.5 radians environ) en 0.2 secondes
	bras_droit.tween_property(epaule_right, "rotation:x", deg_to_rad(-90), 0.2)

func baisser_bras_droit():
	var bras_droit = create_tween()
	bras_droit.tween_property(epaule_right, "rotation:x", 0, 0.2)
