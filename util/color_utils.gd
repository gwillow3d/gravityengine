class_name ColorUtils

static func lerp_hsv(from: Color, to: Color, delta: float) -> Color:
	var d_hue = to.h - from.h
	if d_hue > 0.5: d_hue -= 1.0
	if d_hue < -0.5: d_hue += 1.0
	
	return Color.from_hsv(from.h + d_hue * delta, from.s + (to.s - from.s) * delta, from.v + (to.v - from.v) * delta)
