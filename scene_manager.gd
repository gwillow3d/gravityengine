class_name SceneManager
extends Node

@export var simulation: Simulation
@export var simulation_manager: SimulationManager
@export var camera_controller: CameraController
@export var color_manager: SimulationColorManager
@export var ui_manager: UIManager
@export var glow_renderer: GlowRenderer

func _ready() -> void:
	# Wire signals #
	
	simulation.simulation_reset.connect(color_manager._on_simulation_reset)
	simulation.border_type_changed.connect(camera_controller._on_border_type_changed)
	simulation.world_size_changed.connect(camera_controller._on_world_size_changed)
	
	color_manager.color_changed.connect(glow_renderer._on_color_changed)
	
	# Setup classes #
	
	simulation.setup()
	simulation_manager.setup(simulation)
	ui_manager.setup(simulation, simulation_manager)
