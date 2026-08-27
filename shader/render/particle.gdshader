shader_type canvas_item;

void fragment() {
	vec2 uv = (UV * 2.0) - 1.0;
	float r = length(uv);
	if(r >= 1.0) { COLOR = vec4(0.0); }
	else {
		float alpha = smoothstep(1.0, 0.0, r);
		COLOR.a = alpha * 1.4;
	}
}