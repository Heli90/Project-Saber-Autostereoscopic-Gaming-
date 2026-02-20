# Cube rotatif sur Godot

## Descriptif rapide
> Il s'agit de créer une zone de test où on contrôle un personnage joueur basique qui peut interagir avec un cube flottant via des mouvements qu'il peut contrôler via les touches du clavier. Une extension est prévue prochainement avec la détection de mouvements via Mediapipe.

## Structure du projet

### Cube
> Conçu comme un objet animable en 3D, sa rotation peut être contrôlée par les bras du joueur.
> **Fonctionnalités :**
- Collisions 3D avec le joueur
- Rotation selon l'axe Y via le bras droit du joueur
- Rotation selon l'axe Z via le bras gauche du joueur

### Joueur
> Conçu comme un personnage jouable en 3D, il peut se mouvoir dans l'espace (gauche, droit, avant, arrière) et peut utiliser ses bras pour contrôler la rotation du cube à distance.
> **Fonctionnalités :**
- Collisions 3D avec le cube
- Déplacements basiques via les touches du clavier Z/Q/S/D
- Déclenchement de la rotation du cube via les bras
- Caméra attachée au joueur permettant de suivre le jeu
- Gravité implémentée dans la physique du joueur

### Elements annexes
> Il s'agit des spécificités du projet qui ne sont pas nécessaires, mais qui renforcent le confort de jeu.
- Sol et collision 3D entre le sol et tous les objets
- Lumière de projection sur le cube pour avoir de l'ombre