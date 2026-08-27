shader_type canvas_item;

uniform sampler2D color_map;

void fragment() {
	float l = COLOR.r;
	l = pow(l, 16.0);
	COLOR = texture(color_map, vec2(COLOR.r, 0.0));
}
