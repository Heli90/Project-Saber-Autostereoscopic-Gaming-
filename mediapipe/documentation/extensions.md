# Comment accéder à l'API MediaPipe dans Godot

Il suffit de se rendre à l'adresse suivante : https://github.com/j20001970/GDMP-demo/tree/master/project/addons et de télécharger le dossier `addons` et de les mettre en racine du projet Godot (il faudra ensuite activer l'extension depuis Godot dans Projet->Paramètres du Projet->Extensions).

Parmi les dossiers, les 2 plus importants sont :
- **GDMP** qui est le dossier qui gère l'API en tant que tel
- **CameraServerExtension**, qui facilite l'utilisation des classes `CameraServer` et `CameraFeed`, nécessaire à l'utilisation de la caméra. 


Pour pouvoir ensuite utiliser les différents modules proposés, il faut mettre dans le projet **les fichiers .task** que l'on retrouve à cette adresse :
```
https://storage.googleapis.com/mediapipe-models/"nom_du_modèle"/"nom_du_modèle"/float16/1/"nom_du_modèle.task"
```

Ex :
- hand_landmarker.task : https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task
- gesture_recognizer.task : https://storage.googleapis.com/mediapipe-models/gesture_recognizer/gesture_recognizer/float16/1/face_landmarker.task

Ce sont eux qui spécifient les méthodes utilisés pour chaque type d'objet (marqueurs sur le visage / les mains, reconnaissance de mouvement, etc..)