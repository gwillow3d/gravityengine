shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform int pixel_size = 4;

void fragment() {
	ivec2 size = textureSize(SCREEN_TEXTURE, 0);
	
	int xRes = size.x;
	int yRes = size.y;
	
	float xFactor = float(xRes) / float(pixel_size);
	float yFactor = float(yRes) / float(pixel_size);
	
	float grid_uv_x = round(SCREEN_UV.x * xFactor) / xFactor;
	float grid_uv_y = round(SCREEN_UV.y * yFactor) / yFactor;
	
	vec4 text = texture(SCREEN_TEXTURE, vec2(grid_uv_x, grid_uv_y));
	
	COLOR = text;
}