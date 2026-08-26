class_name SimulationManager
extends Node

signal average_time_updated(time: float)
signal step_rate_updated(steps: int)

@export var simulation: Simulation

var _paused: bool = false
# The step rate prior to the simulation pausing
var _unpaused_steps: int = 1

var _simulation_speed: float = 1.0
var _frame_time_accumulator: float
var _average_progress: float

var steps_per_frame: int = 4

@onready var particle_container: TextureRect = $"../CanvasLayer/UIRoot/WorldContainer/ParticleContainer"

func _ready() -> void:
	await get_tree().process_frame
	simulation.reset()
	step_rate_updated.emit(steps_per_frame)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("pause_simulation"):
			set_paused(!_paused)

func _physics_process(delta: float) -> void:
	if !_paused:
		var start_time = Time.get_unix_time_from_system()
		simulation.step(steps_per_frame)
		var end_time = Time.get_unix_time_from_system()
		
		_frame_time_accumulator += end_time - start_time
		_average_progress += 1
		
		if _average_progress >= 60 - 1:
			var average_time = _frame_time_accumulator / 60
			
			average_time_updated.emit(average_time)
			
			_average_progress = 0
			_frame_time_accumulator = 0

func set_paused(paused: bool) -> void:
	_paused = paused
	if !paused:
		steps_per_frame = max(1, steps_per_frame)
		step_rate_updated.emit(steps_per_frame)
	else:
		step_rate_updated.emit(0) # tells the UI to display "paused"

func set_steps_per_frame(steps: int) -> void:
	if _paused and steps > 0:
		_paused = false
	steps_per_frame = steps
	step_rate_updated.emit(steps)

func set_simulation_speed(speed: float) -> void:
	_simulation_speed = speed
