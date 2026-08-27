class_name ScreenshotNotifier
extends Label

var _tween: Tween

func _ready() -> void:
	hide()

func _on_screenshot_taken(save_path: String) -> void:
	text = "Screenshot saved as %s." % save_path
	
	if _tween:
		_tween.stop()
	
	modulate.a = 0.0
	show()
	
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.4)
	_tween.tween_interval(1.0)
	_tween.tween_property(self, "modulate:a", 0.0, 0.6)
	_tween.tween_callback(hide)
