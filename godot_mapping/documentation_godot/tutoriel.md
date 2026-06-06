# Tutoriel et page d'introduction sur Godot

## Descriptif rapide
> Il s'agit de fournir une page d'introduction pour les joueurs avant de démarrer la partie pour inscrire leurs noms et choisir les modes souhaités pour la partie.

## Structure des scènes associées

### Page d'inscription
> Elle apparaît lorsqu'on clique sur **New Game** depuis le menu principal et a diverses fonctionnalités :
- Inscription facultative des 2 joueurs au classement
- Retourner au menu principal
- Accéder à la page de sélection des niveaux
- Activer ou désactiver le mode à vie limitée
- Choisir une difficulté parmi 3 difficultés possibles (facile, moyen, difficile)

### Page de sélection des niveaux
> Elle apparaît lorsqu'on clique sur **Start** depuis la page d'inscription. Ses fonctionnalités sont les suivantes :
- Choisir le niveau de son choix avec les flèches et les cassettes
- Retourner à la page d'inscription

### Niveau de tutoriel en jeu
> Ce niveau est lancé lorsqu'on clique sur la cassette de tutoriel depuis la page de sélection des niveaux. Celui-ci permet de s'entraîner sur différents types de cubes prédéfinis et leur apparition est aléatoire. Ses fonctionnalités sont les suivantes :
- Choisir les cubes qu'on souhaite faire apparaître via 4 panneaux : classiques, bonus, classiques et bonus, ou bien, tous les cubes
- Lancement du tutoriel avec une apparition aléatoire des cubes choisis
- Changement de mode possible à tout moment en allant dans le menu de pause

### Notes techniques
- Fonction globale d'animation des boutons (réutilisable) :
```gdscript
func ButtonEnter(button, button_scale: Vector2, life = false, sign_sprite: Sprite2D = null,  sign_scale: Vector2 = Vector2(0, 0)) -> void:
	if first_scale_transition: first_scale_transition.kill()
	if loop_scale_transition_button: loop_scale_transition_button.kill()
	if loop_scale_transition_sign: loop_scale_transition_sign.kill()
	if not life: button.material.set_shader_parameter("is_hovered", true)
	
	first_scale_transition = create_tween().set_parallel(true)
	first_scale_transition.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	first_scale_transition.set_ease(Tween.EASE_OUT)
	first_scale_transition.set_trans(Tween.TRANS_BACK)
	if life: first_scale_transition.tween_property(button, "scale", button_scale * HEART_SCALE_FACTOR, SCALE_DURATION)
	else: first_scale_transition.tween_property(button, "scale", button_scale * BUTTON_SCALE_FACTOR, SCALE_DURATION)
	if sign_sprite: first_scale_transition.tween_property(sign_sprite, "scale", sign_scale * (BUTTON_SCALE_FACTOR), SCALE_DURATION)
	await first_scale_transition.finished
	
	loop_scale_transition_button = create_tween().set_loops()
	loop_scale_transition_button.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	loop_scale_transition_button.set_ease(Tween.EASE_OUT)
	loop_scale_transition_button.set_trans(Tween.TRANS_BACK)
	if life:
		loop_scale_transition_button.tween_property(button, "scale", button_scale / (HEART_SCALE_FACTOR ** 2), SCALE_DURATION / 2)
		loop_scale_transition_button.tween_property(button, "scale", button_scale * (HEART_SCALE_FACTOR ** 2), SCALE_DURATION * 2)
	else:
		loop_scale_transition_button.tween_property(button, "scale", button_scale / (BUTTON_SCALE_FACTOR ** 2), SCALE_DURATION / 2)
		loop_scale_transition_button.tween_property(button, "scale", button_scale * (BUTTON_SCALE_FACTOR ** 2), SCALE_DURATION * 2)
	if sign_sprite:
		loop_scale_transition_sign = create_tween().set_loops()
		loop_scale_transition_sign.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		loop_scale_transition_sign.set_ease(Tween.EASE_OUT)
		loop_scale_transition_sign.set_trans(Tween.TRANS_BACK)
		loop_scale_transition_sign.tween_property(sign_sprite, "scale", sign_scale / (BUTTON_SCALE_FACTOR ** 2), SCALE_DURATION / 2)
		loop_scale_transition_sign.tween_property(sign_sprite, "scale", sign_scale * (BUTTON_SCALE_FACTOR ** 2), SCALE_DURATION * 2)

func ButtonExit(button, button_scale: Vector2, life = false, sign_sprite: Sprite2D = null, sign_scale: Vector2 = Vector2(0, 0)) -> void:
	if first_scale_transition: first_scale_transition.kill()
	if loop_scale_transition_button: loop_scale_transition_button.kill()
	if loop_scale_transition_sign: loop_scale_transition_sign.kill()
	if not life: button.material.set_shader_parameter("is_hovered", false)
	
	var out = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	out.set_ease(Tween.EASE_OUT)
	out.set_trans(Tween.TRANS_SINE)
	out.set_parallel(true)
	out.tween_property(button, "scale", button_scale, SCALE_DURATION)
	if sign_sprite: out.tween_property(sign_sprite, "scale", sign_scale, SCALE_DURATION)
```