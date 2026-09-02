shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform int pixel_size = 16;
const float blur_strength = 2.5;

void fragment() {
	ivec2 size = textureSize(SCREEN_TEXTURE, 0);
	
	int xRes = size.x;
	int yRes = size.y;
	
	float xFactor = float(xRes) / float(pixel_size);
	float yFactor = float(yRes) / float(pixel_size);
	
	float grid_uv_x = round(SCREEN_UV.x * xFactor) / xFactor;
	float grid_uv_y = round(SCREEN_UV.y * yFactor) / yFactor;
	
	vec4 text = textureLod(SCREEN_TEXTURE, vec2(grid_uv_x, grid_uv_y), blur_strength);
	float brightness = (text.r + text.g + text.b) / 3.0;
	brightness = min(brightness, 0.1);
	
	float boost = smoothstep(0.0, 1.0, brightness / 0.1) / 8.0;
	COLOR.rgb = text.rgb + vec3(boost, boost, boost);
}