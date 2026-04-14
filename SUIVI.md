## Gaming Autostéréoscopique - Suivi de projet

### Membres :
Hugo BELLE, Birame CISSÉ, Hélias GODARD--DELONGEAS, Adam KHATIRI, Van-Kévin NGUYEN

## Suivi des séances

### Séance 1 - 11/02

> Présentation du sujet Artishow et de la TV avec le réseau (avec démonstrations sur des images de test)

> To-Do List créée :
- **Rendu** :
    * Petit programme de mélange des images (Python)
    * Jeu <-> Mélange dans le GPU
- **Jeu** :
    * Moteur : Godot
    * Textures : arènes, 2 personnages (corps, tête, poing)
    * Boxe : déplacements (à faire plus tard)
- **Caméra** :
    * Implémentation MediaPipe dans Godot : création d'une interface pour la caméra (interface web ?) + squelette
    * Tests de caméra à faire pour voir comment ça marche, via un projet Godot à part (utilisation de templates)

> Réalisation d'un algorithme d'entrelacement d'image sur Python

### Entre la séance 1 et la séance 2

*16/02* :

**Hugo :** Recherche de projets OpenSource à utiliser comme base pour le projet

*19/02* : 

- Elaboration du planning à l'aide de Gantt et et début de répartition des tâches entre les membres :
  - Utilisation de MediaPipe ()
  - Entrelacement des images à partir du moteur de jeu ()
- Familiarisation avec Godot

### Séance 2 - 20/02

> Retour du professeur encadrant (J. Lefeuvre) sur le planning
20/02: 

**Hugo** :  Lecture de la biblio de mediapipe et identification des différents type de mediapipe qui pourraient etre utiles :
mediapipe hands (https://github.com/google-ai-edge/mediapipe/blob/master/docs/solutions/hands.md)
mediapipe pose (https://github.com/google-ai-edge/mediapipe/blob/master/docs/solutions/pose.md)

### Séance 3 - 23/02 (Encadrant absent)

**Hélias** : Premiers essais d'entrelacement de deux images dans Godot. 
Problème pour le moment : j'arrive à entrelacer deux images mais je n'arrive pas à accéder aux deux images désirées (prise de deux caméras)

### Entre la séance 3 et la séance 4

25/02 - **Van-Kévin** : Implémentation de l'algorithme d'entrelacement initié par Hélias. Visuel possible sur la TV avec les 8 vues, et 2 points de vue distincts par joueur, mais les images sont statiques (les caméras sont immobiles). Prise en main des outils de Godot pour préparer un terrain de jeu (son, visuel de terrain...).
04/03 - **Van-Kévin** : Implémentation d'un menu d'entrée du jeu avec transitions de texte et foncionnalités basiques, d'un menu en jeu mettant en pause le jeu. Prise en compte de paramètres de confort de jeu (musique, SFX) et ajout d'un choix de mode PC/TV pour faciliter les futurs tests.
06/03 - **Van-Kévin** : Implémentation d'un temps imparti pour les parties jouées et d'un score final qui peut être enregistré s'il s'agit du meilleur score. Possibilité de réinitialiser ce score dans le menu principal. Reconfiguration de l'ensemble des scènes du jeu pour faciliter la compréhension du code. Implémentation de 2 vues FPS/TPS pour le mode PC (et peut-être le mode TV, plus tard, si besoin) et correction des déplacements des joueurs, en conséquence. Correction de certains bugs liés au mode TV et ajout de caméras mobiles avec le joueur tout en conservant les vues (à confirmer avant la séance 4).

12/03 - **Birame** : Test du projet-test mis à disposition par GDMP (https://github.com/j20001970/GDMP-demo/tree/master) et familiarisation avec les outils utilisés (HandLandmarker.gd et HAndRenderer.gd)

### Séance 4 - 13/03
**Hélias** : récupération des coordonées de la main dans MediaPipe et tests sur la profondeur (plutôt bien détectée par MP mais nouveau problème : si on pose la caméra sur l'écran, les joueurs sont vite trop loin !)
**Van-Kévin** : Modification de la map. Présentation des tests effectués jusqu'à présent. Implémentation d'un texte affiché en jeu pour voir les FPS du jeu courant et le temps de rendu pris par les shaders (faux calcul actuellement).
**Birame** : Tests de l'affichage de la caméra, en vue d'afficher les marqueurs des joueurs

### Séance 5 - 16/03

**Birame** : Affichage des marqueurs sur un autre projet que le GDMP-test ( + les coordonnées : cf Hélias séance 4).
**Hélias** : Détection des "états" de la main avec MediaPipe et recherche de jeux OpenSource à exploiter
**Van-Kévin** : Premier calcul correct du temps de rendu cumulé des vues multiples - temps de rendu cumulé à 30 millisecondes. Ajustement de la résolution des vues pour gagner 33% de temps de rendu cumulé. Tentatives d'optimisation de ce calcul.

### Séance 6 - 27/03

**Van-Kévin** : Tentative d'implémentation d'un "Beat Saber"-like pour avoir un premier aperçu des performances en conditions de jeu réelles.
**Hélias** : Tentative d'implémentation du "Beat Saber"-like avec Van-Kévin, ajout de deux effets visuels dans le projet démo (effet de glitch et inversion des deux yeux)
**Birame** : Ajout de la détection dans le projet `cube_godot` pour gérer la vitesse de rotation du cube (vitesse de rotation du cube modulée par l'abscisse par rapport à la caméra de l'index de la main observée). Affichage de *hand_landmarkers* colorés et du nombre de mains détectées dans `hand-tracking-project`

### Entre la séance 6 et la séance 7

31/03 - **Birame** :
- `hand_tracking_project` : Ajout de la détection de mouvements dans le projet . Affichage des temps de traitement liés à MediaPipe (analyse des données et rendu) et à l'affichage de la caméra.
- `godot_cube` : Ajout de la détection de mouvements dans le jeu : le cube arrête de tourner quand la main observée se ferme (et se remet à tourner pour n'importe quelle autre geste) .
- Mise à jour de la documention (transition de `hand_landmarker.task` à `gesture_recognizer.task`)

### Séance 7 - 03/04

**Van-Kévin** : Correction du calcul de temps de rendu global avec le "Profileur Visuel" de Godot (plutôt correct en sachant qu'il inclut aussi un temps d'entrelacement très faible de l'ordre d'une ms). Aide pour les tests de caméra et l'optmisation des FPS du jeu avec la caméra incluse (car c'est Mediapipe qui fait perdre le plus de FPS).  
**Hélias** : Essai de passage à 3 vues par personnes, passage de MediaPipe dans un thread à part pour gagner en performance.

### Entre la séance 7 et la séance 8

**Van-Kévin** : Correction de bugs liés au thread Mediapipe, modification de la map et implémentation d'une zone de test isolant le cube de test pour faciliter les tests en vue de l'évaluation intermédiaire. Modification de la documentation concernant les fonctionnalités du jeu. Tests de déplacements d'objets effectués avec les marqueurs de main (actuellement supprimés pour qu'on puisse faire la transition avec le marqueur du corps entier).

### Séance 8 - 10/04

**Groupe** Derniers tests : le projet de l'évaluation intermédiaire est foncionnel.

**Hélias** : Actualisation du planning avec des tâches plus précises pour la deuxième phase de développement.

### Entre la séance 8 et la séance 9

**Birame** : Mise en place du trancking de deux corps dans le projet `tracking_projet` (sans couper l'image en deux).

**Van-Kévin** : Ajout d'un pourcentage de score séparé pour chaque joueur et séparation du temps total du GPU entre temps de génération des vues et temps d'entrelacement.

### Séance 9 - 15/04



### Séance 10 - 21/04



### Séance 11 - 05/05



### Séance 12 - 13/05



### Séance 13 - 27/05



### Séance 14 - 10/06



### Séance 15 - 15/06



### Séance 16-20 - Semaine du 22/06