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

25/02 - **Van-Kévin** :
- Implémentation de l'algorithme d'entrelacement initié par Hélias.
- Visuel possible sur la TV avec les 8 vues, et 2 points de vue distincts par joueur, mais les images sont statiques (les caméras sont immobiles).
- Prise en main des outils de Godot pour préparer un terrain de jeu (son, visuel de terrain...).

04/03 - **Van-Kévin** :
- Implémentation d'un menu d'entrée du jeu avec transitions de texte et foncionnalités basiques, d'un menu en jeu mettant en pause le jeu.
- Prise en compte de paramètres de confort de jeu (musique, SFX) et ajout d'un choix de mode PC/TV pour faciliter les futurs tests.

06/03 - **Van-Kévin** :
- Implémentation d'un temps imparti pour les parties jouées et d'un score final qui peut être enregistré s'il s'agit du meilleur score.
- Possibilité de réinitialiser ce score dans le menu principal.
- Reconfiguration de l'ensemble des scènes du jeu pour faciliter la compréhension du code.
- Implémentation de 2 vues FPS/TPS pour le mode PC (et peut-être le mode TV, plus tard, si besoin) et correction des déplacements des joueurs, en conséquence.
- Correction de certains bugs liés au mode TV et ajout de caméras mobiles avec le joueur tout en conservant les vues (à confirmer avant la séance 4).

12/03 - **Birame** : Test du projet-test mis à disposition par GDMP (https://github.com/j20001970/GDMP-demo/tree/master) et familiarisation avec les outils utilisés (HandLandmarker.gd et HAndRenderer.gd)

### Séance 4 - 13/03
**Hélias** : récupération des coordonées de la main dans MediaPipe et tests sur la profondeur (plutôt bien détectée par MP mais nouveau problème : si on pose la caméra sur l'écran, les joueurs sont vite trop loin !)

**Van-Kévin** :
- Modification de la map.
- Présentation des tests effectués jusqu'à présent.
- Implémentation d'un texte affiché en jeu pour voir les FPS du jeu courant et le temps de rendu pris par les shaders (faux calcul actuellement).

**Birame** : Tests de l'affichage de la caméra, en vue d'afficher les marqueurs des joueurs

### Séance 5 - 16/03

**Birame** : Affichage des marqueurs sur un autre projet que le GDMP-test ( + les coordonnées : cf Hélias séance 4).

**Hélias** : Détection des "états" de la main avec MediaPipe et recherche de jeux OpenSource à exploiter

**Van-Kévin** :
- Premier calcul correct du temps de rendu cumulé des vues multiples - temps de rendu cumulé à 30 millisecondes.
- Ajustement de la résolution des vues pour gagner 33% de temps de rendu cumulé. Tentatives d'optimisation de ce calcul.

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

**Van-Kévin** :
- Correction du calcul de temps de rendu global avec le "Profileur Visuel" de Godot (plutôt correct en sachant qu'il inclut aussi un temps d'entrelacement très faible de l'ordre d'une ms).
- Aide pour les tests de caméra et l'optmisation des FPS du jeu avec la caméra incluse (car c'est Mediapipe qui fait perdre le plus de FPS).  

**Hélias** : Essai de passage à 3 vues par personnes, passage de MediaPipe dans un thread à part pour gagner en performance.

### Entre la séance 7 et la séance 8

**Van-Kévin** :
- Correction de bugs liés au thread Mediapipe, modification de la map et implémentation d'une zone de test isolant le cube de test pour faciliter les tests en vue de l'évaluation intermédiaire.
- Modification de la documentation concernant les fonctionnalités du jeu.
- Tests de déplacements d'objets effectués avec les marqueurs de main (actuellement supprimés pour qu'on puisse faire la transition avec le marqueur du corps entier).

### Séance 8 - 10/04

**Groupe :** Derniers tests : le projet de l'évaluation intermédiaire est foncionnel.

**Hélias** : Actualisation du planning avec des tâches plus précises pour la deuxième phase de développement.

### Entre la séance 8 et la séance 9

**Birame** : Mise en place du trancking de deux corps dans le projet `tracking_projet` (sans couper l'image en deux).

**Van-Kévin** : Ajout d'un pourcentage de score séparé pour chaque joueur et séparation du temps total du GPU entre temps de génération des vues et temps d'entrelacement.

### Séance 9 - 15/04

**Birame** : Ajout du tracking du corps dans le projet du jeu.

**Van-Kévin** : Correction de bugs du sélecteur de caméras, début de modélisation 3D pour le jeu.

**Hélias** : Travail sur les effets visuels et notamment de profondeur

### Séance 10 - 21/04

**Groupe :** Evaluation intermédiaire : Echange avec l'encadrant sur l'état actuel du projet et les évoluations à venir (cf `PLANNING.md`)

### Entre la séance 10 et la séance 11

05/05 - **Van-Kévin** : Implémentation de la correction du temps de calcul des vues via GPU dans la branche principale du projet.

### Séance 11 - 05/05

**Van-Kévin** :
- Ajout d'une touche pour bloquer le mouvement de tous les objets pour tester des effets visuels, et d'une touche pour modifier le décalage entre les caméras des vues pour chaque joueur.
- Suppression de certaines touches du joueur liées à la caméra pour mieux correspondre au jeu final.
- Affichage du temps de détection par Mediapipe des mains.
- Modification du terrain pour faire apparaître les joueurs face à face.
- Détection de collision entre les cubes et les joueurs pour se renvoyer le cube.
- Incrémentation de la vitesse du cube grâce à un système de combo.
- Apparition aléatoire des cubes parmi plusieurs positions prédéfinies à un intervalle de temps régulier.

**Groupe** :
- Discussion autour du jeu choisi et des mécaniques à implémenter

### Entre la séance 11 et la séance 12

**Van-Kévin** :
- Dessin de quelques croquis pour avoir une idée globale du design du jeu.
- Ajout d'un score séparé et des multiplicateurs de scores pour chaque joueur.
- Affichage de chaque score en jeu via un visuel en bas à droite de l'écran du joueur.
- Mécaniques de disparition des cubes en jeu sous certaines conditions, décrites dans une nouvelle documentation dédiée au jeu.
- Ajout des cubes de jeu classiques, des cubes donnant un bonus de multiplicateur différenciés selon chaque joueur, des cubes explosifs donnant un malus au joueur et des cubes invisibles valant un très haut score mais qui deviennent invisibles en quelques secondes.
- Animation de spin lorsque les cubes classiques sont frappés par le joueur (pour l'instant, identiques quelque soit la direction où le joueur frappe).
- Ajout d'une seed pseudo-aléatoire pour contrôler le temps d'apparition des cubes donnant un bonus, fixer pseudo-aléatoirement la direction des cubes qui apparaissent sur le terrain, la couleur des cubes classiques et leur vitesse.
- Vitesses individuelles pour chaque cube.
- Notification sur l'écran du joueur en texte pour dire qu'il a touché le cube invisible.
- Développement de la possibilité du retrait du retour caméra tout en conservant la caméra active pour le code du jeu.
- Premier nom proposé pour le jeu (à débattre aux prochaines séances)
- Première musique proposée pour le menu d'accueil (à débattre aux prochaines séances)

**Birame** :
- Implémentation des mouvements des sabres (avec Van-Kévin)
- Commandes et couleur individuelles individuelles par joueur

### Séance 12 - 13/05

**Birame :** Séparation du flux caméra en 2 images (droite et gauche) pour gérer chaque joueur indépendamment (cela rend le tracking de chaque joueur plus précis).
**Van-Kévin :** Implémentation d'un menu de tutoriel et correction de l'orientation des cubes.

### Entre la séance 12 et la séance 13

**Van-Kévin :**
- Calibration des sabres en adéquation avec la séparation du flux caméra.
- Ajout d'un cube jettant de l'encre sur la caméra du joueur qui l'a frappé et d'un cube donnant un bouclier protégeant le joueur, faisant en sorte qu'il ne perde pas de multiplicateur de score s'il rate au maximum 5 cubes classiques pendant 10 secondes. Ajout visuel du bouclier et d'une barre visuelle du bouclier affichant en temps réel ses points de vie au joueur (par tranche de 20 PV) lorsque celui-ci est pris.
- Correction du bug de superposition des scores de chaque joueur en mode TV et d'un bug d'affichage de l'encre en mode TV car certaines vues n'avaient pas d'encre.
- Ajout d'un effet visuel de destruction progressive du bouclier à mesure que des cubes sont ratés et d'une diminution en temps réel de la barre de bouclier.
- Ajout d'un leaderboard fonctionnel enregistrant les noms et les scores associés et d'une page avant le début du jeu en mode TV permettant d'enregistrer les noms de chaque joueur. S'il n'y a pas de noms inscrits, les scores ne sont pas enregistrés.
- Suppression de l'effet de lumière sur le menu principal, qui servait à faire des tests.
- Transfert du mode PC dans le menu du jeu pour pouvoir faire directement des tests sur le menu sans lancer de partie et avoir un menu plus réaliste en vue de la version finale.
- Implémentation d'une barre de progression visuelle montrant le combo de chaque joueur.
- Ajout d'un mode optionnel en vie limitée (seulement, visuellement) et modification du shader pour les vues pour pouvoir appliquer les effets individuellement, à chaque joueur.
- Ajout d'un cube de soin associé à l'implémentation précédente.
- Ajout d'un script global pour contrôler l'activation du mode avec vie limitée.
- Mise à jour de la documentation en lien avec les tâches réalisées ci-dessus.

### Séance 13 - 27/05

- Présentation du projet Artishow lors de l'audit.

### Entre la séance 13 et la séance 14

**Van-Kévin**:
- Ajout fonctionnel du cube de soin et de la barre de soin.
- Modification de l'affichage du classement en fin de partie si un joueur a perdu tous ses points de vie.
- Ajout d'un fade-in et d'un fade-out pour tous les cubes.
- Ajout d'anneaux dans le terrain pour le rendre plus vivant.
- Ajout d'une page de sélection de niveaux (tutoriel, vraie partie) via des animations basiques de cassettes.
- Ajout du SFX associé à la tâche ci-dessus et pour le bouton du mode de vie.
- Ajout de VFX pour tous les boutons des menus.
- Ajout d'un cadre de vidéo pour le menu d'inscription.
- Ajout d'une interface de tutoriel en jeu : sélection des cubes avec lesquels on souhaite s'entraîner via des panneaux, adaptation de la scène de jeu selon les cubes choisis et changement des menus pour changer les cubes en cours d'entraînement dans le tutoriel interactif.
- Modification graphique du jeu : police d'écriture, visuels, images en jeu, fonds d'écran des menus.
- Optimisation de l'utilisation de la caméra : déclenchement uniquement dans les scènes du menu principal et de la partie hors tutoriel.
- Ajout d'un mode de difficulté (utilité visuelle) pour réguler la fréquence d'apparition des cubes.
- Ajout de documentation associée à la page d'inscription, la page de sélection des niveaux et le niveau de tutoriel.

**Birame :**
- Ajustement de l'amplitude de déplacement des bras
- Annulation du traçage des noeuds lorsque l'image n'est pas affichée

### Séance 14 - 10/06

**Van-Kévin :**
- Vérification du bon fonctionnement de la pixelisation et correction des bugs liés à l'effet de pixelisation pendant les combos.
- Ajout d'un bouton pour passer du tutoriel à la vraie partie.
- Modification de la génération des taches d'encres pour rendre les chargements plus rapides.

**Hélias :**
- Contact pour avoir l'emplacement devant Thévenin le jour de la présentation
- Mise en commun des tâches à accomplir, répartition des tâches et actualisation en conséquence du planning 
- Création du form pour les bêta-testeurs

**Birame :**
- Tests pour la calibration des sabres

### Entre la séance 14 et la séance 15

**Van-Kévin :**
- Ajout d'une zone de tests de tous les effets créés au cours du projet, même s'ils ne sont pas retenus dans la version finale, pour faire office de démonstration technique
- Ajout d'un paramètre de modification de l'espace interoculaire de chaque joueur avec une instance de jeu lancée depuis le menu principal pour voir le résultat en temps réel pendant la modification

### Séance 15 - 15/06



### Séance 16-20 - Semaine du 22/06