# Génération des vues sur Godot

## Descriptif rapide
> La scène **generation_image3D** sert à générer les 8 différentes vues à partir de la scène **cube.tscn**.

## Structure de la scène associée

### Gestion des caméras
> On place 8 caméras pour l'ensemble des 2 joueurs qui vont projeter les vues adéquates. Leur ordre est le suivant :
- 2 caméras pour le joueur 1
- 2 caméras qui affichent des images noires
- 2 caméras pour le joueur 2
- 2 caméras qui affichent des images noires

### Application du shader
> On entrelace les pixels en décalant chaque sous-pixel (R,G,B) par un décalage en diagonale.

```gdscript
float get_subpixel_color(int view_index, vec2 uv, int channel) {
    vec3 col;
    if (view_index == 0) {
		col = texture(vue_1, uv).rgb;
	} else if (view_index == 1) {
		col = texture(vue_2, uv).rgb;
	} else if (view_index == 2) {
		col = texture(vue_3, uv).rgb;
    } else if (view_index == 3) {
		col = texture(vue_4, uv).rgb;
    } else if (view_index == 4) {
		col = texture(vue_5, uv).rgb;
    } else if (view_index == 5) {
		col = texture(vue_6, uv).rgb;
    } else if (view_index == 6) {
		col = texture(vue_7, uv).rgb;
    } else {col = texture(vue_8, uv).rgb;
	} return col[channel];
}

void fragment() {
    // Coordonnées en pixels
    int x = int(FRAGCOORD.x);
    int y = int(FRAGCOORD.y);
    
    // Calcul des indices de vue pour chaque composante R, G, B
    int view_r = ((3 * x + 0 + decalage * y) % N + N) % N;
    int view_g = ((3 * x + 1 + decalage * y) % N + N) % N;
    int view_b = ((3 * x + 2 + decalage * y) % N + N) % N;
    
    float r = get_subpixel_color(view_r, UV, 0);
    float g = get_subpixel_color(view_g, UV, 1);
    float b = get_subpixel_color(view_b, UV, 2);
    
    COLOR = vec4(r, g, b, 1.0);
}
```