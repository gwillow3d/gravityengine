class_name GlowRenderer
extends TextureRect

func _on_color_changed(color: Color) -> void:
	var color_map: GradientTexture1D = material.get_shader_parameter("color_map")
	color_map.gradient.set_color(1, color)
