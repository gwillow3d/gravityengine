class_name UIManager
extends Node

signal simulation_reset_requested

@export var fps_label: Label
@export var frame_time_widget: FrameTimeWidget
@export var population_widget: PopualtionWidget

@export var reset_button: Button
@export var speed_slider: HSlider
@export var speed_amount: Label
@export var energy_widget: EnergyWidget
@export var heavy_load_warning: Label
@export var ui_parent: Control
@export var screenshot_widget: ScreenshotNotifier

var _simulation: Simulation
var _manager: TimeManager
var _screenshot: ScreenshotManager

func setup(simulation: Simulation, manager: TimeManager, screenshot: ScreenshotManager) -> void:
	_simulation = simulation
	_manager = manager
	_screenshot = screenshot

func _ready() -> void:
	_manager.step_rate_updated.connect(_on_simulation_rate_updated)
	
	reset_button.pressed.connect(_on_reset_pressed)
	speed_slider.value_changed.connect(_on_slider_changed)
	_simulation.energy_updated.connect(energy_widget._on_energy_updated)
	_simulation.population_changed.connect(population_widget._on_population_changed)
	_manager.average_time_updated.connect(_average_time_updated)
	_manager.average_time_updated.connect(frame_time_widget._on_frame_time_updated)
	_screenshot.screenshot_taken.connect(screenshot_widget._on_screenshot_taken)
	
	update_speed_label(speed_slider.value)

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

func _on_slider_changed(value: float) -> void:
	_manager.steps_per_frame = int(value)
	if speed_amount:
		update_speed_label(value)

func update_speed_label(value: float) -> void:
	var rating = get_speed_rating(value)
	speed_amount.text = "%sx (%s)" % [value / 4, rating]

func get_speed_rating(speed: float) -> String:
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

func _average_time_updated(average_time: float) -> void:
	if average_time * 1000 > 22 and _manager.steps_per_frame > 0:
		heavy_load_warning.visible = true
	else:
		heavy_load_warning.visible = false

func _on_simulation_rate_updated(steps: int) -> void:
	update_speed_label(steps)
	speed_slider.set_value_no_signal(steps)
