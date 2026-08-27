class_name ScreenshotManager
extends Node

signal screenshot_taken(location: String)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("screenshot"):
			var dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES) + "/Gravity Engine/"
			if not DirAccess.dir_exists_absolute(dir):
				DirAccess.make_dir_absolute(dir)
			var filename = Time.get_datetime_string_from_system() + ".png"
			var path = dir + filename
			get_viewport().get_texture().get_image().save_png(path)
			print("Screenshot saved as \"%s\"" % path)
			screenshot_taken.emit(path)
