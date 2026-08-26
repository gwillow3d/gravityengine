class_name SceneManager
extends Node

@export var camera_controller: CameraController
@export var simulation: Simulation
@export var color_manager: SimulationColorManager

func _ready() -> void:
	# SIGNALS #
	simulation.simulation_reset.connect(color_manager._on_simulation_reset)
	
	simulation.border_type_changed.connect(camera_controller._on_border_type_changed)
	simulation.world_size_changed.connect(camera_controller._on_world_size_changed)
	
	simulation.setup()
