# Jeu final sur Godot

## Descriptif rapide
> **Pong Saber** est inspiré du jeu en réalité virtuelle Beat Saber. Il se joue à 2 joueurs et l'objectif pour chacun des deux est d'acquérir le meilleur score en jouant une partie d'environ 2 minutes. Au cours de la partie, ils contrôlent chacun 2 sabres via leurs bras et ils doivent frapper le plus de cubes valides possibles qui arrivent sur leur vue respective.

## Déroulé du jeu
> On lance une partie en mode PC ou TV selon le périphérique utilisé. Au cours de la partie, voici les mécaniques présentes :
- Un **spawner de cubes** en format 3x1 au milieu de l'arène entre les 2 joueurs pour faire apparaître les cubes pour qu'ils se dirigent vers l'un des 2 joueurs
- Un **renvoi de cubes** via l'utilisation de collisions entre les sabres du joueur et les cubes vers l'autre joueur
- Une **destruction des cubes** à partir d'un certain nombre de bons coups donnés selon certaines conditions
- Une **accélération des cubes** à partir de certains paliers de combo
- Un **score** attribué à chacun des joueurs qui s'incrémente en fonction du nombre de cubes frappés, d'affilée et au total

> Différents types de cubes sont ou seront proposés au cours de la partie :
- Cubes **classiques** valant 1000 points de score par défaut
- Cubes **étoilés** valant 5000 points de score par défaut et multipliant les points obtenus de tous les cubes par 2 pendant 10 secondes
- Cubes **explosifs** faisant perdre 500 points de score
- Cubes **invisibles** qui clignotent 3 fois puis disparaissent quelques secondes avant de devoir être frappés valant 15000 points de score par défaut

> Chacun de ces cubes a une mécanique spécifique pour la disparition :
- Cubes classiques : Entre **1** et **3** coups avant disparition, selon la couleur initiale du cube
- Autres cubes : **1** coup avant disparition

## Joueurs
> Chaque joueur est doté de 2 sabres. Les fonctionnalités de ces derniers seront décrites ci-dessous plus tard lorsque les sabres seront réalisés.

## Caméra
> Une caméra est utilisée pour les contrôles des sabres de chaque joueur, qui est détecté par des marqueurs de corps. Deux possibilités de gameplay sont possibles pour les tests :

- Un mode de débuggage avec l'affichage de la caméra et des marqueurs de corps - Pour l'activer, dans le Node **LandMarksProceed**, rendre le SubViewportContainer, le CanvasLayer et le CameraLabel, tous visibles.
- Le mode de jeu classique sans affichage de la caméra - Pour l'activer, il suffit de rendre invisible les trois noeuds cités précedemment. 