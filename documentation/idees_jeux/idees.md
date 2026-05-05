## Mettre ici les différentes pistes et les sources de jeux à faire
- Utiliser des jeux open-source en VR pour avoir déjà deux caméras par joueur

Jeux à utiliser :

Pick-n-Punch : Jeu godot open source qui est un jeu de boxe avec une vue première personne avec un affrontement contre une ia. 
https://github.com/Platymek/Pick-n-Punch/tree/master/.idea/.idea.ThirdYearFinal/.id

OpenSaber : version openSource de BeatSaber pour Godot. Jeu de rythme en VR, on peut dupliquer les pistes pour que les deux joueurs s'affrontent sur le même morceau pour le meilleur score.
https://github.com/leandrodreamer/BeepSaber/tree/godot-4-port


Idées autres :

Utiliser le template: Godot 4 Advanced Third-Person Controller __ NeonfireStudio/godot-advanced-third-person-controller                    
Qui est un template qui permet la gestion d'un personnage 3D et de gerer la caméra dans l'espace. Il permet des mouvements avancés. Il faut utiliser des projets en license MIT pour ajouter des coups pour un jeu de boxe.

Utiliser le template: Godot 4 Third-Person Combat Prototype __ Snaiel/Godot4ThirdPersonCombatPrototype ;                              
Permet un combat leger dans un environnement 3D ainsi que des mouvements

Idées de mécaniques pour le jeu :

- Versus en 1v1 sur le même terrain
- Génération des cubes sur une grille 3x1, puis 3x3 si cela n'est pas trop difficile
- Accélération des cubes quand on frappe correctement le cube
-Frapper le cube avec une certaine inclinaison peut forcer un coup précis pour le joueur adverse
- Score pour chacun des joueurs (parfait/normal/malus)
- Gérer la distance entre les joueurs, la vitesse des cubes et la distance à laquelle on frappe les cubes pour que ça soit jouable
- Effet de rotation de caméra pour se voir avec des points de vues inversés (se voir soi-même, par exemple)