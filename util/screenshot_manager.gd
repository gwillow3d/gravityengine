class_name ScreenshotManager
extends Node

signal screenshot_taken(location: String)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("screenshot"):
			var filename = Time.get_datetime_string_from_system() + ".png"
			var image = get_viewport().get_texture().get_image()
			if OS.get_name() == "Web":
				_save_screenshot_from_web(image, filename)
			else:
				_save_screenshot_from_desktop(image, filename)

func _save_screenshot_from_web(image: Image, filename: String) -> void:
	var buffer := image.save_png_to_buffer()
	JavaScriptBridge.download_buffer(buffer, filename, "image/png")
	print("Screenshot saved as \"%s\"" % filename)
	screenshot_taken.emit(filename)

func _save_screenshot_from_desktop(image: Image, filename: String) -> void:
	var dir = OS.get_system_dir(OS.SYSTEM_DIR_PICTURES) + "/Gravity Engine/"
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_absolute(dir)
	var path = dir + filename
	image.save_png(path)
	print("Screenshot saved as \"%s\"" % path)
	screenshot_taken.emit(path)
