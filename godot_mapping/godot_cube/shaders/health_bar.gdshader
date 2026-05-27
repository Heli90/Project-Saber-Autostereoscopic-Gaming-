shader_type canvas_item;

void fragment() {
    vec4 left = vec4(0.9, 0.5, 0.1, 1.0);   // orange
    vec4 right = vec4(1.0, 0.0, 0.2, 1.0);  // rouge
    COLOR = mix(left, right, UV.x);
}