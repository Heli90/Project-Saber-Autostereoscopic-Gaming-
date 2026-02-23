shader_type spatial;

uniform sampler2D texture_gauche;
uniform sampler2D texture_droit;
uniform float resolution_y = 1080.0;
uniform float resolution_x = 1920.0;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv=UV;
	vec4 couleur_gauche = texture(texture_gauche, uv);
	vec4 couleur_droit = texture(texture_droit, uv);
	
	// Positions du pixel
	float pixel_x = floor(uv.x * resolution_x);
	float pixel_y = floor(uv.y * resolution_y);

	// Entrelacement 
	vec3 albedo;
	if (mod(pixel_x, 2.0) == mod(pixel_y,2.0)){
		albedo.r = 0.0;
		albedo.g = 0.0;
		albedo.b = 0.0;
	} else {
		albedo.r = 1.0;
		albedo.g = 1.0;
		albedo.b = 1.0;
	}
	
	ALBEDO = albedo;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
