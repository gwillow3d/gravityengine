class_name SpeedWidget
extends VBoxContainer

signal speed_value_changed(to: int)

@export var speed_label: Label
@export var speed_slider: Slider

func _ready() -> void:
	speed_slider.value_changed.connect(_on_slider_changed)
	
	_update_speed_label(speed_slider.value)

func _on_simulation_rate_updated(steps: int) -> void:
	_update_speed_label(steps)
	speed_slider.set_value_no_signal(steps)
	
func _on_slider_changed(value: float) -> void:
	speed_value_changed.emit(value)
	_update_speed_label(value)

func _update_speed_label(value: float) -> void:
	var rating = _get_speed_rating(value)
	speed_label.text = "%sx (%s)" % [value / 4, rating]

func _get_speed_rating(speed: float) -> String:
	if speed == 0:
		return "Paused"
	elif speed < 4:
		return "Slow"
	elif speed < 8:
		return "Normal"
	elif speed < 12:
		return "Fast"
	elif speed < 16:
		return "Very Fast"
	else:
		return "Max"
