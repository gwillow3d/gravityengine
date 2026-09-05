class_name SimulationManager
extends Node

signal render_mode_changed(mode: RenderMode)

@onready var sub_viewport: SubViewport = $"../SubViewport"
@onready var simulation_data: TextureRect = $"../SubViewport/SimulationData"

@export var render_mode: RenderMode = RenderMode.FastGPU

@export var fast_presets: Array[SimulationConfig]
@export var fancy_presets: Array[SimulationConfig]

@export var simulation: Simulation
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
		if is_fastcpu_available():
			render_mode = RenderMode.FastCPU
		else: render_mode = RenderMode.Legacy
	
	if render_mode == RenderMode.Legacy:
		simulation._simulation_instance = CPUSimulation.new()
		simulation._config = fast_presets[randi_range(0, fast_presets.size() - 1)]
	elif render_mode == RenderMode.FastCPU:
		simulation._simulation_instance = FastCPUSimulation.new()
		simulation._config = fast_presets[randi_range(0, fast_presets.size() - 1)]
	elif render_mode == RenderMode.GPU:
		simulation._simulation_instance = GPUSimulation.new()
		simulation._simulation_instance.simulation_viewport = sub_viewport
		simulation._simulation_instance.simulation_data = simulation_data
		simulation._config = fancy_presets[randi_range(0, fancy_presets.size() - 1)]
	else:
		simulation._simulation_instance = FastGPUSimulation.new()
		simulation._config = fancy_presets[randi_range(0, fancy_presets.size() - 1)]
	
	# Wire signals #
	
	simulation.simulation_reset.connect(color_manager._on_simulation_reset)
	simulation.world_size_changed.connect(debug_boundary_renderer._on_simulation_size_changed)
	simulation.border_type_changed.connect(debug_boundary_renderer._on_simulation_border_type_changed)
	simulation.border_type_changed.connect(camera_controller._on_border_type_changed)
	simulation.world_size_changed.connect(camera_controller._on_world_size_changed)
	simulation.population_changed.connect(particle_renderer._on_population_changed)
	simulation.population_changed.connect(background_renderer._on_population_changed)
	
	color_manager.color_changed.connect(glow_renderer._on_color_changed)
	
	ui_manager.simulation_reset_requested.connect(_on_simulation_reset)
	
	# Setup classes #
	
	simulation.setup()
	simulation_manager.setup(simulation)
	particle_renderer.setup(simulation)
	background_renderer.setup(simulation)
	ui_manager.setup(self, simulation, simulation_manager, screenshot_manager)
	
	call_deferred("_broadcast_render_mode")

func _broadcast_render_mode() -> void:
	render_mode_changed.emit(render_mode)

func _on_simulation_reset() -> void:
	var config: SimulationConfig
	
	if render_mode == RenderMode.Legacy:
		config = fast_presets[randi_range(0, fast_presets.size() - 1)]
	else:
		config = fancy_presets[randi_range(0, fancy_presets.size() - 1)]
	
	simulation.reset(config)

func is_fastcpu_available() -> bool:
	return ClassDB.class_exists("FastCPUSimulation")

enum RenderMode {
	Legacy,
	FastCPU,
	GPU,
	FastGPU,
}
