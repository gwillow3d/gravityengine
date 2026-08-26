extends Label

func _process(delta: float) -> void:
	text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
@export var negative_percentage: float = 0.2
