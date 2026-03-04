# Cube rotatif sur Godot

## Descriptif rapide
> Il s'agit de créer une zone de test où on contrôle un personnage joueur basique qui peut interagir avec un cube flottant via des mouvements qu'il peut contrôler via les touches du clavier. Une extension est prévue prochainement avec la détection de mouvements via Mediapipe.

## Structure de la scène associée

### Cube
> Conçu comme un objet animable en 3D, sa rotation peut être contrôlée par les bras du joueur.
> **Fonctionnalités :**
- Collisions 3D avec le joueur
- Rotation selon l'axe Y via le bras droit du joueur
- Rotation selon l'axe Z via le bras gauche du joueur

### Joueurs
> Conçus comme des personnages jouables en 3D, ils peuvent se mouvoir dans l'espace (gauche, droit, avant, arrière). Un mode en écran divisé est prochainement prévu pour les tests sur PC.
> **Fonctionnalités :**
- Collisions 3D avec le cube
- Déplacements basiques via les touches du clavier Z/Q/S/D

```gdscript
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
	move_and_slide()```

- Caméra attachée au joueur permettant de suivre le jeu
- Gravité implémentée dans la physique du joueur

### Elements annexes
> Il s'agit des spécificités du projet qui ne sont pas nécessaires, mais qui renforcent le confort de jeu.
- Sol et collision 3D entre le sol et tous les objets
- Lumière de projection sur le cube pour avoir de l'ombre