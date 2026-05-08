shader_type spatial;
//render_mode unshaded;

uniform vec4 color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 center_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	float v = smoothstep(1.0 - dot(NORMAL, VIEW), 0.0, 0.15);
	
	ALBEDO = center_color.rgb;
	EMISSION = color.rgb * max(0.1, v) * 2.0;
	
	float st = smoothstep(0.7, 1.2, 1.0-v);
	EMISSION += vec3(st * 0.01);
	EMISSION *= vec3(1.0 + st * 60.0);
}

