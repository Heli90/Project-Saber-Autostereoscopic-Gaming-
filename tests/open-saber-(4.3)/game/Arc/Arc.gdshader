shader_type spatial;

uniform vec4 color: source_color;
uniform float emission = 2.0;
uniform sampler2D noise;
uniform float noise_pow = 3.0;
uniform float noise_mult = 2.2;
uniform vec2 noise_scale = vec2(0.3,3.0);
uniform float noise_speed = 0.3;

uniform int saber_magnet : hint_range(0, 2, 1) = 0;

uniform float distance_fade_min : hint_range(0.0, 4096.0, 0.01);
uniform float distance_fade_max : hint_range(0.0, 4096.0, 0.01);
uniform float distance_fade_magnet_min : hint_range(0.0, 4096.0, 0.01);
uniform float distance_fade_magnet_max : hint_range(0.0, 4096.0, 0.01);
uniform float distance_fade_tip_min : hint_range(0.0, 4096.0, 0.01);
uniform float distance_fade_tip_max : hint_range(0.0, 4096.0, 0.01);

uniform float distance_effect : hint_range(0.01, 4096.0, 0.01);
uniform float distance_power : hint_range(0.01, 4096.0, 0.01);

varying float to_discard;
varying float dist;
varying float tip_dist;
global uniform vec3 left_saber;
global uniform vec3 right_saber;

void vertex() {
	tip_dist = length(VERTEX);

	vec3 saber_pos = left_saber;
	if (saber_magnet == 0){
		saber_pos = vec3(0.0,0.0,9999.0);
	}else if (saber_magnet == 2){
		saber_pos = right_saber;
	}

	vec3 wrld_pos = NODE_POSITION_WORLD + VERTEX;
	dist = abs(wrld_pos.z - saber_pos.z);
	float force = max(0.0, 1.0 - (dist / distance_effect));
	VERTEX = mix(wrld_pos, saber_pos,
		pow(force, distance_power) * min(tip_dist / distance_fade_tip_max, 1.0)
		) - NODE_POSITION_WORLD;
	to_discard = float(wrld_pos.z > saber_pos.z);
}

void fragment() {
	if (to_discard > 0.5){discard;}
	float fade = clamp(smoothstep(distance_fade_min, distance_fade_max, length(VERTEX)), 0.0, 1.0);
	float magnet_fade = clamp(smoothstep(distance_fade_magnet_max, distance_fade_magnet_min, distance_fade_magnet_max+distance_fade_magnet_min - dist), 0.0, 1.0);
	float tip_fade = clamp(smoothstep(distance_fade_tip_min, distance_fade_tip_max, tip_dist), 0.0, 1.0);
	ALPHA = color.a * min(min(fade, magnet_fade), tip_fade);
	ALPHA *= clamp(pow(texture(noise, UV*noise_scale+vec2(TIME*noise_speed,0.0)).r, noise_pow) * noise_mult, 0.0, 1.0);
	ALBEDO = color.rgb;
	EMISSION = color.rgb * emission;

}
