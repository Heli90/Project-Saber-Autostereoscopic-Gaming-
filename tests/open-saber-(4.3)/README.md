# Open Saber VR
This is a fork of [Beep Saber by NeoSpark314](https://github.com/NeoSpark314/BeepSaber) ported to Godot 4.3 and OpenXR (WIP)
(The OQ Toolkit is only partially ported/patched for it to work on Godot 4 with OpenXR, most features that are not used in this project will not work)

This fork tries to improve the experience and make it more of it's own game instead of just a demo.



This is a basic implementation of the beat saber game mechanic for VR using the [Godot Game Engine](https://godotengine.org/) and the [Godot Oculus Quest Toolkit](https://github.com/NeoSpark314/godot_oculus_quest_toolkit). The main objective of this project is to show how a VR game can be implemented using
the Godot game engine.

The main target platform is the Oculus Quest but it should also work with SteamVR if you add the OpenVR plugin to the addons folder in the godot project.

Originally this game was (and still is) a demo game as part of the Godot Oculus Quest Toolkit. To keep the demo implementation small
this stand alone version was forked so that it can be changed and developed independent of the original demo.

![screenshot01](doc/images/OS0.4.0_1.gif)
![screenshot02](doc/images/OS0.4.0_2.gif)
![screenshot03](doc/images/OS0.4.0_3.gif)
# About the implementation
This game uses godot 4.3. The implementation supports to load and play maps from [BeatSaver](https://beatsaver.com/).
To export for android headsets the godot openxr vendors plugin may be needed

There is one demo song included that is part of the deployed package.

You can play custom songs by downloading them in the in-game menu. 

# Credits
The included Music Track is Time Lapse by TheFatRat (https://www.youtube.com/watch?v=3fxq7kqyWO8)

# Licensing
The source code of the godot beep saber / open saber game in this repository is licensed under an MIT License.


## Traduction 
## Projet Open Source

### Open Saber VR

Notre projet s appuie en partie sur Open Saber VR qui est un fork de Beep Saber développé par NeoSpark314

Open Saber VR est une adaptation de Beep Saber vers Godot 4 et OpenXR dont l objectif est de proposer une implémentation des mécaniques de Beat Saber tout en servant de démonstration technique des capacités du moteur Godot pour les jeux immersifs

Projet original

Open Saber VR  
https://github.com/Hixor/open-saber

Beep Saber  
https://github.com/NeoSpark314/BeepSaber

### À propos de l implémentation

Le projet Open Saber VR utilise Godot 4 et permet notamment le chargement et la lecture de cartes provenant de BeatSaver

Parmi les fonctionnalités disponibles dans le projet original on retrouve

- Gestion des cubes et du rythme de jeu inspirés de Beat Saber
- Système de score
- Lecture de cartes musicales
- Téléchargement de musiques personnalisées depuis le jeu
- Compatibilité OpenXR pour les casques VR

Notre projet reprend certaines idées et une partie de l architecture du projet original mais les adapte à un contexte totalement différent

Les principales modifications apportées sont

- Remplacement de la réalité virtuelle par un affichage sur télévision autostéréoscopique
- Remplacement des contrôleurs VR par une détection des mouvements à l aide d une caméra externe et de MediaPipe
- Ajout d un mode multijoueur local à deux joueurs
- Mise en place d une mécanique hybride entre Beat Saber et Pong où les cubes peuvent être renvoyés à l adversaire
- Ajout de menus spécifiques à l expérience multijoueur
- Développement d effets visuels adaptés à l affichage stéréoscopique sans lunettes

### Technologies utilisées

Le projet Open Saber VR a servi de base de travail pour plusieurs systèmes du jeu notamment

- La gestion des cubes
- La logique de frappe
- Le système de score
- L organisation des scènes de jeu
- Certains éléments de gameplay inspirés de Beat Saber

Ces éléments ont ensuite été adaptés et étendus afin de répondre aux contraintes du projet Gaming Autostéréoscopique Project Saber

### Crédits

Le projet original inclut la piste musicale

Time Lapse par TheFatRat

https://www.youtube.com/watch?v=3fxq7kqyWO8

### Licence

Le code source du projet Open Saber VR et du projet Beep Saber est distribué sous licence MIT

Les développements réalisés dans le cadre du projet Gaming Autostéréoscopique Project Saber ont été adaptés et étendus pour répondre aux objectifs du projet universitaire
