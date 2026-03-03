shader_type canvas_item;

uniform float lod: hint_range(0.0, 5.0) = 2.0; // Intensité du flou
uniform float brightness: hint_range(0.0, 1.0);
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Récupération de l'image de fond et effet de flou
    COLOR = textureLod(screen_texture, SCREEN_UV, lod);
    COLOR *= brightness;
}