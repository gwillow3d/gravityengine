class_name PerformanceWidgets
extends Node

@export var fps_label: Label
@export var frame_time_label: Label
@export var population_label: Label
@export var render_mode_label: Label

func _process(_delta: float) -> void:
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	fps_label.text = "%.0f FPS" % fps

func _on_frame_time_updated(frame_time: float) -> void:
	frame_time_label.text = "%.0fms per frame" % [frame_time * 1000]

func _on_population_changed(population: int) -> void:
	population_label.text = "%s particles" % population

func _on_render_mode_updated(mode: SimulationManager.RenderMode) -> void:
	render_mode_label.text = "%s mode" % SimulationManager.RenderMode.find_key(mode)
