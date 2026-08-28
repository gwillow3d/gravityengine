class_name RenderModeWidget
extends Label

func _ready() -> void:
	hide()

func _on_render_mode_updated(mode: SimulationManager.RenderMode) -> void:
	show()
	text = "%s mode" % SimulationManager.RenderMode.find_key(mode)
