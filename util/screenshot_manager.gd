class_name ScreenshotManager
extends Node

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("screenshot"):
			var path = Time.get_datetime_string_from_system() + ".png"
			get_viewport().get_texture().get_image().save_png(path)
			print("Screenshot saved as \"%s\"" % path)
