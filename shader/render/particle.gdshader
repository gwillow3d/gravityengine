shader_type canvas_item;
render_mode blend_premul_alpha;

uniform sampler2D black_hole_gradient;

void fragment() {
	vec2 uv = (UV * 2.0) - 1.0;
	float r = length(uv);
	if(COLOR.r > 0.0) {
		float alpha = smoothstep(1.0, 0.0, r);
		COLOR.a = alpha * 4.0;
	} else {
		COLOR = texture(black_hole_gradient, vec2(smoothstep(0.0, 1.0, r), 0.0));
	}
	COLOR.rgb *= COLOR.a;
}