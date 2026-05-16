shader_type canvas_item;

void fragment() {
    vec4 left = vec4(0.2, 0.5, 0.9, 1.0);   // bleu
    vec4 right = vec4(0.0, 0.85, 0.8, 1.0);  // cyan/turquoise
    COLOR = mix(left, right, UV.x);
}