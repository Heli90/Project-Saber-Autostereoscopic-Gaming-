extends CharacterBody3D

@export var player_speed1 = 5.0
@export var player_speed2 = 5.0
@export var head_rotation = 1.0
@export var inertie = 3.0
@export var player_id = 1
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var pivot_vertical = $PivotCamera
@onready var son_marche = $Son_Marche

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("GaucheJ%s"%player_id, "DroiteJ%s"%player_id, "AvancerJ%s"%player_id, "ReculerJ%s"%player_id)
	var dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if dir:
		if player_id == 1:
			velocity.x = dir.x * player_speed1
			velocity.z = dir.z * player_speed1
		elif player_id == 2:
			velocity.x = dir.x * player_speed2
			velocity.z = dir.z * player_speed2
		if not son_marche.playing:
			son_marche.pitch_scale = randf_range(0.9, 1.1)
			son_marche.play()
		son_marche.volume_db = lerpf(son_marche.volume_db, 0, 10 * delta)
	else:
		son_marche.volume_db = lerpf(son_marche.volume_db, -80, 0.5 * delta)
		if player_id == 1:
			velocity.x = move_toward(velocity.x, 0, player_speed1)
			velocity.z = move_toward(velocity.z, 0, player_speed1)
		elif player_id == 2:
			velocity.x = move_toward(velocity.x, 0, player_speed2)
			velocity.z = move_toward(velocity.z, 0, player_speed2)

	# Application de la vélocité et gestion des collisions
	move_and_slide()

func _process(delta: float) -> void:
	var dir_rotation = 0.0
	
	# Rotation HORIZONTALE (on fait tourner tout le corps du joueur)
	if Input.is_action_pressed("TeteGaucheJ1"):
		dir_rotation += 1.0
	elif Input.is_action_pressed("TeteDroiteJ1"):
		dir_rotation -= 1.0
	var ry = lerpf(0, dir_rotation, inertie * delta)
	rotate_y(ry)
	
	var dir_vertical = 0.0
	if Input.is_action_pressed("TeteHautJ1"):
		dir_vertical += 1.0
	if Input.is_action_pressed("TeteBasJ1"):
		dir_vertical -= 1.0
	var rx = lerpf(0, dir_vertical, inertie * delta)
	pivot_vertical.rotate_x(rx)
	
	# Limiter la rotation verticale pour ne pas faire de salto avec la vue
	pivot_vertical.rotation.x = clamp(pivot_vertical.rotation.x, deg_to_rad(-80), deg_to_rad(80))

@onready var epaule_right = $Epaule_Right
@onready var epaule_left = $Epaule_Left

func _input(event):
	if event.is_action_pressed("Contrôle du bras droitJ1"):
		lever_bras_droit()
	elif event.is_action_pressed("Contrôle du bras gaucheJ1"):
		lever_bras_gauche()
	elif event.is_action_released("Contrôle du bras droitJ1"):
		baisser_bras_droit()
	elif event.is_action_released("Contrôle du bras gaucheJ1"):
		baisser_bras_gauche()
		
func lever_bras_gauche():
	var bras_gauche = create_tween()
	# On fait tourner l'épaule de 90 degrés en 0.2 secondes
	bras_gauche.tween_property(epaule_left, "rotation:y", deg_to_rad(-90), 0.2)

func baisser_bras_gauche():
	var bras_gauche = create_tween()
	bras_gauche.tween_property(epaule_left, "rotation:y", 0, 0.2)

func lever_bras_droit():
	var bras_droit = create_tween()
	# On fait tourner l'épaule de 90 degrés en 0.2 secondes
	bras_droit.tween_property(epaule_right, "rotation:y", deg_to_rad(90), 0.2)

func baisser_bras_droit():
	var bras_droit = create_tween()
	bras_droit.tween_property(epaule_right, "rotation:y", 0, 0.2)
