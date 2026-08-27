shader_type canvas_item;
render_mode blend_premul_alpha;

void fragment() {
	vec2 uv = (UV * 2.0) - 1.0;
	float r = length(uv);
	float alpha = smoothstep(1.0, 0.0, r);
	COLOR.a = alpha * 1.4;
	COLOR.rgb *= COLOR.a;
}