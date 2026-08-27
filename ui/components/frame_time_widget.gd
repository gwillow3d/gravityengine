class_name FrameTimeWidget
extends Label

func _on_frame_time_updated(frame_time: float) -> void:
	text = "%.0fms per frame" % [frame_time * 1000]
