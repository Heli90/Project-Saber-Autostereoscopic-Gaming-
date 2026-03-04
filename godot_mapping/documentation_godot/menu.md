# Menu sur Godot

## Descriptif rapide
> Il s'agit de fournir un menu permettant d'alterner entre les différents modes de jeu et de fournir des outils ergonomiques pour lancer une partie et quitter le jeu, une fois que la détection de mouvements sera réalisée.

## Structure des scènes associées

### Menu d'entrée
> Il apparaît au démarrage du jeu et a diverses fonctionnalités :
- Commencer le jeu avec le choix du mode 1 joueur (pour l'instant) sur son PC, ou du mode 2 joueurs sur la TV
- Paramètres : Ils permettent de régler les paramètres de musique et de SFX.
- Crédits : Ils affichent les personnes en charge du projet.
- Quitter le jeu

### Menu en jeu
> Il apparaît lorsqu'on appuie sur Echap et permet de mettre en pause le jeu. Ses fonctionnalités sont les suivantes :
- Reprendre le jeu
- Paramètres identiques
- Retourner au menu d'entrée
- Quitter le jeu

### Notes techniques
- Transition de texte (exemple) :
```gdscript
var transition = create_tween().set_parallel(true)
	transition.tween_property(menu_buttons, "modulate:a", 0.0, 0.1)
	transition.set_parallel(false)
	transition.chain().tween_interval(0.1)
	transition.tween_callback(func():
		options.modulate.a = 0.0
		menu_buttons.visible = false
		options.visible = true)
	transition.tween_property(options, "modulate:a", 1.0, 0.1)
	await transition.finished```