shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

vec4 overlay(vec4 base, vec4 blend){
    vec4 limit = step(0.5, base);
    return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}


void fragment() {
    vec3 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 1.0).rgb;
    c.r = 1.0 - c.r;
    c.g = 1.0 - c.g;
    c.b = 1.0 - c.b;
    COLOR = overlay(COLOR, vec4(c, 0.0));
}