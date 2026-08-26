class_name SimulationColorManager
extends Node

signal color_changed(color: Color)

@export var _simulation: Simulation
@export var hue_shift_speed: float = 4.0

var _new_color: Color = Color.BLACK
var _current_color: Color

func _ready() -> void:
	_randomize_simulation_color()

func _process(delta: float) -> void:
	if _new_color != _current_color:
		_new_color = ColorUtils.lerp_hsv(_new_color, _current_color, delta * hue_shift_speed)
		color_changed.emit(_new_color)
	
func _on_simulation_reset() -> void:
	_randomize_simulation_color()

func _randomize_simulation_color() -> void:
	_current_color = Color.from_hsv(randf(), 1.0, 1.0)
