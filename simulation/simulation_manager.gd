class_name SimulationManager
extends Node

var simulation: Simulation

@export var default_cpu_config: SimulationConfig
@export var default_gpu_config: SimulationConfig

@export var simulation_manager: TimeManager
@export var camera_controller: CameraController
@export var color_manager: HueManager
@export var ui_manager: UIManager
@export var glow_renderer: GlowRenderer
@export var screenshot_manager: ScreenshotManager

@export var particle_renderer: ParticleRenderer
@export var background_renderer: BackgroundRenderer

@export var debug_boundary_renderer: DebugBoundaryLayer

func _ready() -> void:
	if OS.get_name() == "Web":
		simulation = CPUSimulation.new()
		simulation.config = default_cpu_config
	else:
		simulation = GPUSimulation.new()
		simulation.config = default_gpu_config
	
	# Wire signals #
	
	simulation.simulation_reset.connect(color_manager._on_simulation_reset)
	simulation.world_size_changed.connect(debug_boundary_renderer._on_simulation_size_changed)
	simulation.border_type_changed.connect(debug_boundary_renderer._on_simulation_border_type_changed)
	simulation.border_type_changed.connect(camera_controller._on_border_type_changed)
	simulation.world_size_changed.connect(camera_controller._on_world_size_changed)
	simulation.population_changed.connect(particle_renderer._on_population_changed)
	simulation.population_changed.connect(background_renderer._on_population_changed)
	
	color_manager.color_changed.connect(glow_renderer._on_color_changed)
	
	# Setup classes #
	
	simulation.setup()
	simulation_manager.setup(simulation)
	particle_renderer.setup(simulation)
	background_renderer.setup(simulation)
	ui_manager.setup(simulation, simulation_manager, screenshot_manager)
