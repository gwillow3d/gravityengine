shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

const float threshold = 0.6;

void fragment() {
	if(COLOR.a > 0.0) {
		vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 2.0);
		float luminance = (color.r + color.g + color.b) / 3.0;
		if(luminance > threshold) {
			luminance = (luminance - threshold) / (1.0 - threshold);
			float key = smoothstep(threshold, 0.0, luminance);
			COLOR.rgb = vec3(key, key, key);
		}
	}
}