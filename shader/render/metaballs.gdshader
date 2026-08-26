shader_type canvas_item;

uniform float blur_radius : hint_range(0.0, 20.0) = 5.0;
uniform vec2 viewport_size = vec2(1280.0, 720.0);
uniform float threshold = 0.6;
uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
    vec2 pixel = blur_radius / viewport_size;
	vec2 uv = UV / 1.0;
	
	vec4 original_color = texture(TEXTURE, uv);
    vec4 color = vec4(0.0);
    int samples = 0;

    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            color += texture(TEXTURE, uv + vec2(float(x), float(y)) * pixel);
            samples++;
        }
    }
	
	color = color / float(samples);
	if(color.a < threshold) {
		color.a = 0.0;
	} else {
		float brightness = (color.r + color.g + color.b) / 3.0;
		brightness = round(brightness);
		color = vec4(brightness, brightness, brightness, 1.0);
	}
	
	COLOR = original_color + color;
}