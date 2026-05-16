# Menu sur Godot

## Descriptif rapide
> Il s'agit de fournir un menu permettant d'alterner entre les différents modes de jeu et de fournir des outils ergonomiques pour lancer une partie et quitter le jeu, une fois que la détection de mouvements sera réalisée.

## Structure des scènes associées

### Menu d'entrée
> Il apparaît au démarrage du jeu et a diverses fonctionnalités :
- Commencer le jeu avec le choix du mode 2 joueurs sur son PC, ou du mode 2 joueurs sur la TV
- Dans le cas du mode 2 joueurs sur la TV, une inscription au classement peut être réalisée via des noms et les scores sont alors enregistrés dans le classement final affiché en fin de partie sur le menu de fin de jeu.
- Paramètres : Ils permettent de régler les paramètres de musique et de SFX.
- Crédits : Ils affichent les personnes en charge du projet.
- Quitter le jeu

### Menu en jeu
> Il apparaît lorsqu'on appuie sur Echap et permet de mettre en pause le jeu. Ses fonctionnalités sont les suivantes :
- Reprendre le jeu
- Paramètres identiques
- Retourner au menu d'entrée
- Quitter le jeu
- Ouvrir un sélecteur de caméra

> Un shader est réalisé sur le menu en jeu, ce qui rend flou l'ensemble du terrain en 3D qui se situe en arrière-plan.

### Notes techniques
- Fonction globale de transition de texte (réutilisable) :
```gdscript
func transition(appear_list: Array[Control], disappear_list: Array[Control], back: bool) -> void:
	# Effectue une transition courante entre 2 pages du menu
	click_sound.play()
	if back:
		# On annule le spam d'appui de boutons
		for button in main_buttons.get_children():
			button.disabled = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	var t = create_tween().set_parallel(true)
	for panel in disappear_list:
		t.tween_property(panel, "modulate:a", 0.0, 0.1)
	t.set_parallel(false)
	t.chain().tween_interval(0.1)
	t.tween_callback(func():
		for panel in disappear_list:
			panel.visible = false
		if appear_list == []:
			fondu_noir.modulate.a = 0.0
			fondu_noir.visible = true
		else:
			for panel in appear_list:
				panel.modulate.a = 0.0
				panel.visible = true)
	t.set_parallel(true)
	if back:
		for panel in appear_list: 
			for button in panel.get_children():
				button.modulate = Color.BLACK
	if appear_list == []:
		# Il y a un changement de scène, donc, on fait un fondu.
		t.set_parallel(false)
		t.tween_property(fondu_noir, "modulate:a", 1.0, 0.5)
		t.chain().tween_interval(0.3)
	else:
		for panel in appear_list:
			t.tween_property(panel, "modulate:a", 1.0, 0.1)
		t.set_parallel(false)
	await t.finished
	
	if back:
		# On annule le spam d'appui de boutons
		for panel in appear_list:
			for button in panel.get_children():
				button.disabled = false
		# On remet la couleur initiale lorsque le curseur passe sur un bouton
			for button in panel.get_children():
				button.modulate = Color.WHITE
```