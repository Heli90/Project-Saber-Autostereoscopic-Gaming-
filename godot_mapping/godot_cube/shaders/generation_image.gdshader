shader_type canvas_item;

// Pour le moment, les vues 1,2,5,6 sont utilisées pour l'affichage, le reste est noir
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

// Variables pour les effets visuels
// 1. Inversion de vues
uniform bool invertViews = false;
// 2. Glitch
uniform float offset = 0.000;
// 3. Pixelisation
uniform bool pixelisation = false;
uniform float pixelisationPower = 200.0;
uniform bool pixelisation_mask[8];
// 4. Recoloration
uniform float intensity_color: hint_range(0., 1.) = 0.5;
uniform bool red_screen = false;
uniform bool green_screen = false;
uniform bool blue_screen = false;
// 5. Effet arc-en-ciel
uniform bool rainbow_screen = false;
uniform float rainbow_speed: hint_range(0., 10.) = 0.5;
uniform float rainbow_angle: hint_range(0., 360.) = 0.;
// 6. Effet de nausée
uniform bool nausea_screen = false;
uniform float nausea_strength: hint_range(0., 0.05) = 0.01;
uniform float nausea_speed: hint_range(0., 5.) = 1.0;
uniform bool nausea_mask[8];
// 7. Effet de vignette
uniform bool vignette_screen = false;
uniform float vignette_strength: hint_range(0., 1.) = 0.5;

vec2 nausea_texture(vec2 uv){
	float a = sin(uv.y * 8.0 + TIME * nausea_speed) * nausea_strength;
	float b = cos(uv.x * 6.0 + TIME * nausea_speed * 0.7) * nausea_strength;
	return uv + vec2(a,b);
}

// Fonction utilitaire pour récupérer la couleur du bon point de vue
float get_subpixel_color(int view_index, vec2 init_uv, int channel) {
	vec2 uv = init_uv;
	// On applique les effets associés aux UV au tout début
	if (nausea_screen && nausea_mask[view_index]) {
		uv = nausea_texture(init_uv);
	}
	
	// On applique la pixelisation dès le départ sur les vues concernées
    if (pixelisation && pixelisation_mask[view_index]) {
        uv = floor(uv * vec2(pixelisationPower)) / pixelisationPower;
    } vec3 col;
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

vec4 rainbow_texture(vec2 uv) {
	float hue = uv.x * cos(radians(rainbow_angle)) - uv.y * sin(radians(rainbow_angle));
    hue = fract(hue + fract(TIME * rainbow_speed));
	
    float x = 1.0 - abs(mod(hue / (1.0 / 6.0), 2.0) - 1.0);
    vec3 rainbow;
    if (hue < 1.0/6.0){rainbow = vec3(1., x, 0.);}
    else if (hue < 1.0/3.0){rainbow = vec3(x, 1., 0.);}
    else if (hue < 0.5){rainbow = vec3(0., 1., x);}
    else if (hue < 2.0/3.0){rainbow = vec3(0., x, 1.);}
    else if (hue < 5.0/6.0){rainbow = vec3(x, 0., 1.);}
    else {rainbow = vec3(1., 0., x);}
    return vec4(rainbow, 1.0);
}

vec3 vignette_texture(vec2 uv, vec4 original_color, bool color){
	vec2 centered = uv - vec2(0.5);
    float dist = length(centered);
    float vignette = smoothstep(0.3, 0.75, dist);
	return mix(original_color.rgb, vec3(0.0), vignette * vignette_strength);
}

void fragment() {
    // Coordonnées en pixels
    int x = int(FRAGCOORD.x);
    int y = int(FRAGCOORD.y);
    
    // Calcul des indices de vue pour chaque composante R, G, B
    int view_r = ((3 * x + 0 + decalage * y) % N + N) % N;
    int view_g = ((3 * x + 1 + decalage * y) % N + N) % N;
    int view_b = ((3 * x + 2 + decalage * y) % N + N) % N;
	
	vec2 uv = UV;
    float r = get_subpixel_color(view_r, uv+vec2(offset,0), 0);
    float g = get_subpixel_color(view_g, uv-vec2(offset,0), 1);
    float b = get_subpixel_color(view_b, uv+vec2(0,offset), 2);
	   
    vec4 original_color = vec4(r, g, b, 1.0);
	vec4 teinte = vec4(1.0);
	if (vignette_screen){original_color.rgb = vignette_texture(UV, original_color, false);}
	if (red_screen){teinte = vec4(1.0, 0.3, 0.3, 1.0);}
	if (green_screen){teinte = vec4(0.3, 1.0, 0.3, 1.0);}
	if (blue_screen){teinte = vec4(0.3, 0.3, 1.0, 1.0);}
	if (rainbow_screen){teinte = rainbow_texture(UV);}
	COLOR = mix(original_color, original_color * teinte, intensity_color);
}