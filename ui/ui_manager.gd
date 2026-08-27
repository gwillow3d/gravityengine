class_name UIManager
extends Node

@export var reset_button: Button
@export var speed_slider: HSlider
@export var speed_amount: Label
@export var energy_label: Label
@export var fps_label: Label
@export var render_time_label: Label
@export var population_label: Label
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
	_simulation.energy_updated.connect(_on_energy_updated)
	#manager.simulation.population_changed.connect(_on_population_changed)
	_manager.average_time_updated.connect(_average_time_updated)
	_screenshot.screenshot_taken.connect(screenshot_widget._on_screenshot_taken)
	
	update_speed_label(speed_slider.value)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("toggle_ui") and ui_parent:
			ui_parent.visible = !ui_parent.visible

func _process(delta: float) -> void:
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	fps_label.text = "FPS: %s" % fps
	
func _on_reset_pressed() -> void:
	_simulation.reset()

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

func _on_energy_updated(kinetic: float, potential: float, linear_momentum: Vector2, angular_momentum: float) -> void:
	var total = kinetic + potential
	energy_label.text = "~ Energy ~\nTotal: %.0f J\nKinetic: %.0f J\nPotential: %.0f J\nLinear M: %.2v Ns\nAngular M: %.2f kJs" % [total, kinetic, potential, linear_momentum, angular_momentum / 1000]

func _average_time_updated(average_time: float) -> void:
	render_time_label.text = "Render Time: %.1f" % [average_time * 1000]

	if average_time * 1000 > 10 and _manager.steps_per_frame > 0:
		heavy_load_warning.visible = true
	else:
		heavy_load_warning.visible = false

func _on_population_changed(population: int) -> void:
	population_label.text = "Population: %s" % population

func _on_simulation_rate_updated(steps: int) -> void:
	update_speed_label(steps)
	speed_slider.set_value_no_signal(steps)
