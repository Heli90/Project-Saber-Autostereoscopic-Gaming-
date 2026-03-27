shader_type spatial;
render_mode cull_disabled;

uniform vec3 left_color: source_color;
uniform vec3 right_color: source_color;

void fragment() {
	if (UV.y < 0.375) { // straps and front
		if (UV.x < 0.375) {
			ALBEDO = vec3(0.0);
		} else {
			ALBEDO = vec3(0.125);
		}
	} else if (UV.y > 0.625) { // cubes
		if (UV.x < 0.5) {
			ALBEDO = left_color;
			EMISSION = left_color * 0.25;
		} else {
			ALBEDO = right_color;
			EMISSION = right_color * 0.25;
		}
	} else { // arrows
		ALBEDO = vec3(1.0);
		EMISSION = vec3(1.0);
	}
}
