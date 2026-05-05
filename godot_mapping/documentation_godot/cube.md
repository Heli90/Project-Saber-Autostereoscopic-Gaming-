# Cube rotatif sur Godot

## Descriptif rapide
> Il s'agit de créer une zone de test où on contrôle un personnage joueur basique qui peut interagir avec un cube flottant via des mouvements qu'il peut contrôler via les touches du clavier. Une extension est prévue prochainement avec la détection de mouvements via Mediapipe.

## Structure de la scène associée

### Cube
> Conçu comme un objet animable en 3D, sa rotation peut être contrôlée par les bras du joueur.
> **Fonctionnalités :**
- Collisions 3D avec le joueur
- Rotation selon l'axe Y pour des tests
- Placé dans une zone de test accessible via le menu pour faciliter les tests

### Joueurs
> Conçus comme des personnages jouables en 3D, ils peuvent se mouvoir dans l'espace (gauche, droit, avant, arrière). Un mode en écran divisé est prévu pour les tests sur PC ainsi que deux modes de caméras (FPS/TPS). Ces derniers sont configurés dans une scène attitrée **joueur.tscn**.
> **Fonctionnalités :**
- Collisions 3D avec le cube
- Déplacements basiques via les touches du clavier Z/Q/S/D pour le joueur 1 et les flèches du clavier pour le joueur 2
- Saut avec Espace pour le joueur 1, Tab pour le joueur 2
- Appui sur les touches A et E pour modifier le décalage interoculaire pour le joueur 1, et les touches W et C pour modifier le décalager interoculaire pour le joueur 2
- Caméra attachée au joueur permettant de suivre le jeu
- Gravité implémentée dans la physique du joueur

```gdscript
var is_fps : bool = true
if not is_on_floor():
		velocity += get_gravity() * delta

	# Saut manuel du joueur.
	if Input.is_action_just_pressed("SautJ%s"%player_id) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Rotation manuelle de la caméra.
	if Input.is_action_just_pressed("Left_CamJ%s"%player_id):
		camera_controller_fps.rotate_y(deg_to_rad(30))
	if Input.is_action_just_pressed("Right_CamJ%s"%player_id):
		camera_controller_fps.rotate_y(deg_to_rad(-30))

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
```

### Connexion entre le cube et Mediapipe
> Différentes interactions sont possibles avec les détecteurs de mains et la position des mains influe le comportement du cube.
> **Fonctionnalités** :
- Possibilité de réguler la vitesse de rotation du cube par rapport à la position horizontale du doigt d'une main
- Possibilité d'arrêter la rotation du cube lorsque la main fait un signe en forme de poing et de la relancer dès qu'on arrête de faire le signe en forme de poing

### Elements annexes
> Il s'agit des spécificités du projet qui ne sont pas nécessaires, mais qui renforcent le confort de jeu.
- Sol et collision 3D entre le sol et tous les objets
- Lumière de projection sur le cube pour avoir de l'ombre
- Timer de partie égal à 60 secondes pour fixer une durée limitée de partie
- Score final affichable à la fin de la partie et enregistrement/suppression possible du meilleur score
- Terrain inspiré du jeu Beat Saber en vue de l'évaluation finale