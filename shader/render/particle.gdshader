shader_type canvas_item;

uniform sampler2D black_hole_gradient;

void fragment() {
	vec2 uv = (UV * 2.0) - 1.0;
	float r = length(uv);
	if(r >= 1.0) { COLOR = vec4(0.0); }
	else {
		COLOR.a = 1.0;
	}
}