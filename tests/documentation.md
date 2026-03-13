## projet-test-gdmp

#### Pour obtenir les coordonées de la main

On affiche les valeurs x,y,z des objets de result.hand_landmarks.landmarks
Le code qui permet cela se trouve à partir de la ligne 49 du ficher vision/HandLandmarker.gd
Attention : beaucoup de coordonnées sont prises en compte (pour les différents points de la main) donc l'affichage peut overflow

## affichage 3D
Le projet Godot suivant permet de tester l'entrelacement de deux images pour avoir un rendu 3D avec l'écran autostéréoscopique

#### Lancer le projet
Le projet s'ouvre dans l'éditeur Godot avec le fichier project.godot

#### Description
Le but du projet est d'afficher en 3D un cyclindre.
Pour cela, on récupère les images de deux caméras (faisant face au cylindre, translatée d'une faible distance) qu'on vient entrelacer dans un shader et afficher sur un écran qu'on observe avec une dernière caméra et qui affiche ce qu'elle voit.

#### Détails

##### main.tscn
C'est la scène principale. Voici l'arborescence des objets :
![arborescence](godot/arborescence_godot.png)

WorldEnvironment : déclare l'environnement à afficher (celui observé par les caméras)

MeshInstance3D : le cylindre à observer

ViewPortDroit : permet de récupérer les données de la caméra droite (noeuf enfant) pour en faire un texture entrelaçable

ViewPortGauche : permet de récupérer les données de la caméra gauche (noeuf enfant) pour en faire un texture entrelaçable

FinalViewMesh : l'écran virtuel qui affiche l'image entrelacée

finalCamera : la caméra qui regarde FinalViewMesh pour l'afficher sur l'écran réel

##### new_script.gd
C'est le script principal du projet.
On y récupère les images de caméra grâce aux viewports pour les envoyer au shader qui entrelace l'image.

##### displayShader.gdshader
C'est le fichier qui gère l'entrelacement.
Il récupère les textures des deux caméras gauche et droite pour les mélanger.
Pour chaque pixel, on regarde sa position modulo 2 et on colore les sous-pixels en conséquence.

Il ne fonctionne pas pour le moment

##### simpleDisplay.gdshader
C'est un shader de test qui entrelace du noir et du blanc.
Il permet de vérifier que le code d'entrelacement fonctionne bien (ce qui signifie que le problème vient de la récupération des images des caméras).