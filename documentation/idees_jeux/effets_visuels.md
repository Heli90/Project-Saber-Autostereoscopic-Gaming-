## Présentation
Ce document regroupe les idées (implémentées ou non) d'effets visuels utilisant la profondeur, l'écran autostéréoscopique ou autre pour le projet final.

## Échange des vues 
On échange les deux caméras correspondant aux deux yeux du joueur.
Effet implémenté (touche I) mais ne change pas grand chose à la vue du joueur.


## GlitchEffect
On décale l'affichage des couleurs, dans différentes directions. 
Effet implémenté : chaque appui sur la touche O décale légèrement les couleurs. SHIFT+O reset le décalage

## Inversion de profondeur
On fait évoluer la profondeur du cube dans le sens inverse de son affichage. Ainsi le cube avance vers nous mais rétrécit.
NON IMPLÉMENTÉ 

## Effet 8-Bit
Pixelisation de la vue
Implémenté : chaque appui sur P pixelise un peu plus la vue. SHIFT+P enlève l'effet.

## Profondeur/Jaillissement
Pour donner un effet de 3D qui sort de l'écran, on utilise les réglages de frustum que Godot offre.
cam.near permet de fixer la distance du plan minimal à partir duquel la caméra voit. En effet de profondeur, plus cam.near est faible, plus les objets paraîtront loin, notamment les sabres. On fixe cam.near à 0.5.

Pour l'effet de profondeur en lui-même, on crée une fonction update_frustum dans global.md pour la rendre accessible à toute les scène. 
Cette fonction, lorsque appelée, modifie l'effet de profondeur en fonction des paramètres demandés.
Concrètement, la fonction repose sur la ligne   
    cam.frustum_offset = Vector2(eye_offset * cam.near/ convergence, 0.0)  
Régler le frustum_offset de chacune des deux caméras permet de décaler légerement le cône (le frustum plus précisemment) qu'elles voient et ainsi faire converger les vues en un point désiré pour donner l'effet de profondeur.  
cam.frustum_offset est un vecteur de taille 2 : la première valeur est le décalage horizontal, et la seconde est la décalage vertical, qui ne nous intéresse pas.  
La formule utilisée est eye_offset * cam.near / convergence  
    - eye_offset est la distance entre les deux yeux, les deux caméras, divisée par deux (c'est la distance des caméras au zéro si on le fixe bien entre les deux yeux)  
    - cf ci-dessus pour cam.near  
    - le paramètre convergence est celui sur lequel on joue pour calibrer l'effet. Si convergence est grand, l'offset final est faible et les deux yeux sont parallèles, regardent à l'infini. Si convergence est faible, l'offset final est très grand et la point de convergence se situe avant l'infini. Les objets derrière le point de convergence semble en profondeur et ceux derrière semble en jaillissement.  


On peut ensuite jouer sur le paramètre convergence pour désorienter le joueur pendant la partie.

### Limites
L'effet est tout de même faible. On a retiré les murs pour l'amplifier mais avec uniquement deux vues et donc peu de mouvement possible, il est dur de voir correctement les effets de parallaxe qui aident beaucoup à percevoir la 3D.
De plus, mal calibré, il peut vite provoquer maux de tête et fatigue oculaire, d'où l'interêt d'un calibrage (disponible dans la scène scene_camera soit le calibrage interoculaire)
