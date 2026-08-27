shader_type canvas_item;
render_mode blend_add;

void fragment() {
	float significance = COLOR.r;
	significance = pow(significance, 0.1);
	vec2 uv = (UV * 2.0) - 1.0;
	float r = length(uv);
	float intensity = smoothstep(1.0, 0.0, r);
	intensity = pow(intensity, 38.0) * significance;
	COLOR = vec4(intensity, intensity, intensity, 1.0);
}