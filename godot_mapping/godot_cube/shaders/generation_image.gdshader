shader_type canvas_item;

// Pour le moment les vues 1,2,3,5,6,7 sont utilisées pour l'affichage, le reste est noir
uniform sampler2D vue_1; 
uniform sampler2D vue_2; 
uniform sampler2D vue_3;
uniform sampler2D vue_4;
uniform sampler2D vue_5; 
uniform sampler2D vue_6; 
uniform sampler2D vue_7;
uniform sampler2D vue_8;

uniform int N = 8;
uniform int decalage = -1;

//Variables pour effets visuels
uniform bool invertViews = false; 
uniform float offset = 0.000;
uniform bool pixelisation = false;
uniform float pixelisationPower = 200.0;


// Fonction utilitaire pour récupérer la couleur du bon point de vue
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
    } else {col = texture(vue_8, uv).rgb;}
	
	// Effet d'inversion
	if (invertViews){
		if (view_index == 0) {
			col = texture(vue_2, uv).rgb;
		} else if (view_index == 1) {
			col = texture(vue_1, uv).rgb;
    	} else if (view_index == 4) {
			col = texture(vue_6, uv).rgb;
    	} else if (view_index == 5) {
			col = texture(vue_5, uv).rgb;
		}
	} 
	
	return col[channel];
}

void fragment() {
    // Coordonnées en pixels
    int x = int(FRAGCOORD.x);
    int y = int(FRAGCOORD.y);
    
    // Calcul des indices de vue pour chaque composante R, G, B
    int view_r = ((3 * x + 0 + decalage * y) % N + N) % N;
    int view_g = ((3 * x + 1 + decalage * y) % N + N) % N;
    int view_b = ((3 * x + 2 + decalage * y) % N + N) % N;
    
    float r = get_subpixel_color(view_r, UV+vec2(offset,0), 0);
    float g = get_subpixel_color(view_g, UV-vec2(offset,0), 1);
    float b = get_subpixel_color(view_b, UV+vec2(0,offset), 2);
	
	if (pixelisation){
		vec2 pixelUV = floor(UV * vec2(pixelisationPower))/pixelisationPower;
		r = get_subpixel_color(view_r, pixelUV, 0);
    	g = get_subpixel_color(view_g, pixelUV, 1);
    	b = get_subpixel_color(view_b, pixelUV, 2);
	}
		
    
    COLOR = vec4(r, g, b, 1.0);
}