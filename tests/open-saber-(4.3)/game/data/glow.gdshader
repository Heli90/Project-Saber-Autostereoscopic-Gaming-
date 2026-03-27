shader_type spatial;
render_mode cull_disabled, blend_add;

uniform sampler2D screen : hint_screen_texture;
uniform float blur = 0.1;
uniform int passes = 1;
uniform bool time = false;
uniform float brightness = 0.8;
uniform float curve = 0.8;
uniform float thressold = 0.3;

float random (vec2 uv, bool power) {
	float val = fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123);
	if (!power){return val;}
	return (1.0 - pow(val, curve));
}

void fragment() {
	vec3 final = vec3(0, 0, 0);
	for (int i = 0; i < passes; i++){
		float dir = PI*2.0 * random(SCREEN_UV+vec2(0.0,-0.001*float(i)), false);
		float rand = random(SCREEN_UV+vec2(0.2 * sin(TIME*0.1) * float(time),0.001*float(i)), true);
		vec2 uv_offset = vec2(sin(dir), cos(dir)) * rand * blur;
		vec3 t = texture(screen, SCREEN_UV + uv_offset).rgb;
		final += t * smoothstep(thressold-0.1, thressold, (t.r+t.g+t.b)/3.0);
	}
	final /= float(passes);
	ALBEDO = final * brightness;
}
