## INTRODUCTION
Ce fichier est une description précise des différents éléments de jeu à mettre en place. Elle peut changer au cours du temps en fonction notamment des tests et des limites qui nous seront imposées (temps, précision médiapipe...)

## Objets et décors
### Cubes
Les cubes sont les objets que vont s'échanger les deux joueurs. Il s'agit de cube de couleur [à déterminer] et de taille [à déterminer]. Ils se déplacent selon une trajectoire prédéfinie arrivant au niveau du joueur sur l'un des rails.
Différents types de cubes ont différents comportements :
- le cube classique ([description visuelle]) est renvoyé à l'adversaire lorsqu'il est frappé
- le cube invisible ([description visuelle]) disparait quelques secondes avant d'arriver devant le joueur qui doit alors anticiper le rail d'arrivée du cube grâce à sa trajectoire ainsi que le moment de son arrivée grâce à sa vitesse. Une fois frappé, il est renvoyé en tant que cube invisible à l'adversaire.
- le cube bombe ([description visuelle]) compte comme un coup raté lorsque le joueur le frappe.
- le cube chanceux ([decription visuelle]) se comporte comme un cube normal mais attribue au mutliplicateur de score une nouvelle valeur aléatoire entre le valeur actuelle et le plafond.

### Sabres
Les sabres sont l'arme dont dispose chacun des joueurs. Ils sont controlés par les mouvements des bras du joueur (un par bras). Ils peuvent ainsi frapper sur les différents rails à leur disposition pour toucher les cubes.

### Rails
Lignes invisibles (ou non), les rails définissent la trajectoire classique des cubes : ligne droite d'un joueur à l'autre. Ils représentent également les différentes zones où le joueur peut frapper.

### Vitre
Le terrain de jeu des joueurs est séparé par une vitre teinté [couleur à déterminer] qui permet de différencier le cube situé chez l'adversaire des siens.

### Décors
[À déterminer], les vues non utilisés prennent la même couleur que le fond du décor (probablement noir) pour une transition visuelle plus agréable.

## Mécaniques et gameplay
### Principe de base
Deux joueurs s'affrontent face à face. Les joueurs n'ont pas de corps mis à part les sabres contrôlés par les bras.
Un cube apparait et se dirige à une vitesse de base vers le joueur 1 sur l'un des trois rails -> À gauche, il faut taper le cube du bras gauche, à droite, du bras droit, au milieu, de l'un des deux bras. Si le joueur échoue à toucher le cube, un nouveau cube est lancé, cette fois vers le joueur 2. Sinon, au contact du sabre, la vitesse du cube est inversé et multiplié par un facteur [à déterminer] et il se dirige alors sur la même voie vers le joueur 2. Le jeu continue ainsi en allant de plus en plus vite entre les joueurs jusqu'à la fin du temps imparti de [à déterminer].

### Score
Chaque joueur commence avec 0 points. Réussir à frapper le cube rapporte 100*multiplicateur points.
Le multiplicateur est initié à 1 et incrémenté de 1 tous les 3 coups réussis avec un plafond à x[à déterminer].
Chaque coup raté réinitialise le multiplicateur à 1.
Le joueur avec le plus de point à la fin du temps imparti gagne.

### Complexifications
- La précision du lien sabre/MédiaPipe pourrait nous permettre (ou non) d'augmenter le nombre de rails de déplacement des cubes.
- Les cubes peuvent prendre des trajectoires non linéaires : en diagonale ou circulaire et le joueur doit alors anticiper sur quel rails il se trouvera au moment de frapper.
- L'angle de frappe peut induire sur la trajectoire de renvoi du cube (frapper sur le côté gauche du cube peut par exemple le renvoyer en diagonale ou le déplcer sur le rail de droite)
- Tous les [à déterminer] points, des effets visuels dérangeants ou des cubes spéciaux sont envoyés à l'adversaire.

### Effets visuels 
voir effets_visuels.md


## Design
[Mettre des croquis]