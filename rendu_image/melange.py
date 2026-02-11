""" !-! IMPORTATION DES MODULES !-! """
import numpy as np
import sys
from PIL import Image

""" !-! CONFIGURATION INITIALE !-! """
decalage = -1        # Décalage vertical pour l'entrelacement
N = 8                # Nombre de vues
largeur = 1920       # Largeur finale de l'image
hauteur = 1080       # Hauteur finale de l'image

""" !-! FONCTION PRINCIPALE !-! """
def melange(images, output):
    assert (len(images) == N), f"Le nombre d'images doit être {N}."
    images = [Image.open(p).convert("RGB") for p in images] # Chargement des images

    # Vérifier les tailles des images
    largeur_base, hauteur_base = images[0].size
    for img in images:
        if img.size != (largeur_base, hauteur_base): raise ValueError("Toutes les images doivent avoir la même taille.")
    
    # On crée une copie de chaque image en une version redimensionnée    
    resized_images = []
    for p in images:
        img = Image.open(p).convert("RGB").resize((largeur, hauteur), Image.Resampling.LANCZOS)
        resized_images.append(np.array(img))

    # Image finale aux dimensions voulues
    resultat = np.zeros((hauteur, largeur, 3), dtype = np.uint8)

    # Entrelacement des sous-pixels par composante R, G, B
    for x in range(largeur):
        for y in range(hauteur):
            for c in range(3): # Dans l'ordre : R, G, B
                subpixel_index = 3 * x + c
                new_pixel = (subpixel_index + decalage * y) % N
                resultat[y, x, c] = resized_images[new_pixel][y, x, c]

    # ------------------------------------------------------
    # Exemples pour illustrer la logique d'entrelacement :
    # - Pour x = 0, y = 0 : R = 0, G = 1, B = 2
    # - Pour x = 1, y = 0 : R = 3, G = 4, B = 5
    # - Pour x = 2, y = 0 : R = 6, G = 7, B = 0
    
    # - Pour x = 0, y = 1 : R = 7, G = 0, B = 1
    # - Pour x = 0, y = 2 : R = 6, G = 7, B = 0
    # ------------------------------------------------------

    # Sauvegarde de l'image en FULL HD
    Image.fromarray(resultat).save(output)

if __name__ == "__main__":
    if len(sys.argv[1::]) != 9:
        print("Il manque des arguments : 8 chemins d'images et 1 chemin de sortie.")
        sys.exit(1)

    melange(sys.argv[1:9], sys.argv[9])