# Gaming Autostéréoscopique : Project Saber

## Description
Jeu à 2 joueurs en écran plein sur une télévision autostéréoscopique où chaque joueur doit frapper des cubes et éventuellment les renvoyer à l'autre joueur sous forme d'un Pong, avec des sabres inspirés de Beat Saber.

---

## Table des matières

- [Aperçu](#aperçu)
- [Structure du projet](#structure-du-projet)
- [Projet intermédiaire](#projet-intermédiaire)
- [Projet final](#projet-final)
  - [Structure du projet](#structure-du-projet)
  - [Fonctionnalités du projet final](#fonctionnalités-du-projet-final)
    - [Menu principal](#menu-principal-)
    - [Page d'inscription et de sélection des niveaux](#page-dinscription-des-joueurs-et-de-sélection-des-niveaux-)
    - [Tutoriel interactif](#tutoriel-interactif-)
    - [Partie](#partie-)
    - [Diaporama d'effets](#diaporama-deffets-)
- [Installation](#installation)
- [Collaborateurs](#collaborateurs)

---

## Aperçu

> Inspiration de Pong et de Beat Saber :
- 2 joueurs contrôlant chacun 2 sabres à l'aide de leurs bras qui sont détectés à l'aide d'une caméra extérieure au jeu
- Frapper les cubes qui arrivent sur chacun des joueurs pour incrémenter son score et de les renvoyer à l'autre joueur

> Le joueur ayant le meilleur score gagne la partie.

---

## Projet intermédiaire

Dans le but d'appréhender la télévision stéréoscopique et le lien à faire entre le jeu et la télévision, notre équipe a dû élaborer un projet intermédiaire de tests, sans créer le jeu final, pour pouvoir mettre en visualisation nos travaux sur cette même télévision.

### Contenu du projet intermédiaire

- Zone plate avec un cube tournant en 3D dans laquelle 2 joueurs peuvent se déplacer de façon basique
- 8 caméras permettant de fixer 2 points de vue distincts par joueurs avec des paires de caméras (1/2 : J1, 5/6: J2, 3/4/7/8: Vues noires pour marquer le décalage entre les 2 joueurs)
- Détection basique des mouvements des mains par la caméra : possibilité d'interagir avec le monde 3D en mettant en pause le jeu avec un poing fermé

---

## Projet final

### Structure du projet

```
res://
├── addons/
|   ├── assets/
|   ├── CameraServerExtension
|   ├── GDMP
|   ├── sfx
├── hand_landmarker/
├── models/
├── pose_landmarker/
├── scenes/
│   ├── game_scenes/
|   |   ├── cubes/
|   |   ├── map/
|   ├── menus/
|   ├── sound/
├── scripts/
│   ├── game_scenes/
|   |   ├── cubes/
|   |   ├── map/
|   |   ├── visuals/
|   ├── menus/
|   ├── sound/
└── shaders/
```

---

### Fonctionnalités du projet final

---
#### **Menu principal :**
**Contenu :**
- Ouvrir le menu principal
- Commencer une nouvelle partie en lançant la page d'inscription
- Ouvrir et / ou modifier les paramètres décrits ci-dessous
- Ouvrir les crédits
- Quitter le jeu

**Paramètres accessibles :**
- Musique
- SFX
- Espace interoculaire
- Calibration des sabres en X et en Y
- Classement actuel

---
#### **Page d'inscription des joueurs et de sélection des niveaux :**
**Contenu :**
- Vidéo de démonstration en mode PC pour faire comprendre le concept du jeu aux joueurs
- Noms à remplir pour l'inscription au classement final
- Cassettes permettant de lancer le mode de son choix (tutoriel interactif, partie, diaporama d'effets)

**Paramètres accessibles :**
- Activation ou désactivation du mode à vie limitée
- Choix d'un mode de difficulté

---
#### **Tutoriel interactif :**
**Contenu :**
- Cadres de sélection des cubes qu'on souhaite faire apparaître pendant le tutoriel
- Possibilité de changer les cubes à tout instant du tutoriel
- Possibilité de passer directement à la partie

---
#### **Partie :**
**Contenu :**
- Partie réelle avec l'inclusion du score de chacun des joueurs
- Menu de fin affichant le nom du gagnant et le classement final des 10 meilleurs joueurs enregistrés jusqu'à cette partie

---
#### **Diaporama d'effets :**
**Contenu :**
- Visualisation de tous les effets gardés, ou non, pour la partie en guise de démonstration technique :
  - Effet d'inversion de vues
  - Effet de pixelisation
  - Effet de glitch
  - Effet de changement de couleur (R,G,B)
  - Effet d'arc-en-ciel en mouvement
  - Effet de nausée
  - Effet de vignette

---

## Installation
### Gitlab
Pour lier un dossier de sa machine au git, utiliser la commande suivante dans le dossier :
```
git remote add origin https://gitlab.telecom-paris.fr/proj104/2025-2026/gaming-as.git
```

### Jeu
Lancer le dossier godot_mapping/godot_cube dans **Godot 4.6**.

## Collaborateurs
Projet développé par Hugo BELLE, Birame CISSÉ, Hélias GODARD--DELONGEAS, Adam KHATIRI, Van-Kévin NGUYEN.
Projet encadré par Jean LEFEUVRE.