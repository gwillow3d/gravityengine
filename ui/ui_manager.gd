class_name UIManager
extends Node

signal simulation_reset_requested

@export var ui_parent: Control

@export var fps_label: Label
@export var frame_time_widget: FrameTimeWidget
@export var population_widget: PopualtionWidget

@export var energy_widget: EnergyWidget
@export var render_mode_widget: RenderModeWidget
@export var screenshot_widget: ScreenshotNotifier

@export var heavy_load_warning: Label
@export var speed_widget: SpeedWidget

@export var reset_button: Button

var _manager: SimulationManager
var _simulation: Simulation
var _time: TimeManager
var _screenshot: ScreenshotManager

func setup(manager: SimulationManager, simulation: Simulation, time: TimeManager, screenshot: ScreenshotManager) -> void:
	_manager = manager
	_simulation = simulation
	_time = time
	_screenshot = screenshot

func _ready() -> void:
	_time.step_rate_updated.connect(speed_widget._on_simulation_rate_updated)
	
	reset_button.pressed.connect(_on_reset_pressed)
	speed_widget.speed_value_changed.connect(_time.set_steps_per_frame)
	_simulation.energy_updated.connect(energy_widget._on_energy_updated)
	_simulation.population_changed.connect(population_widget._on_population_changed)
	_time.average_time_updated.connect(_average_time_updated)
	_time.average_time_updated.connect(frame_time_widget._on_frame_time_updated)
	_screenshot.screenshot_taken.connect(screenshot_widget._on_screenshot_taken)
	
	_manager.render_mode_changed.connect(render_mode_widget._on_render_mode_updated)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("toggle_ui") and ui_parent:
			ui_parent.visible = !ui_parent.visible
		elif event.is_action_pressed("toggle_energy_widget"):
			energy_widget._on_visibility_toggled()

func _process(delta: float) -> void:
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	fps_label.text = "%.0f FPS" % fps
	
func _on_reset_pressed() -> void:
	simulation_reset_requested.emit()

func _average_time_updated(average_time: float) -> void:
	if average_time * 1000 > 17 and _time.steps_per_frame > 1:
		heavy_load_warning.visible = true
	else:
		heavy_load_warning.visible = false
