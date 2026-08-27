class_name SimulationConfig
extends Resource

@export var world_size: Vector2i = Vector2i(500, 500)
@export var generator: Generator = null
@export var border_type: Simulation.BorderType = Simulation.BorderType.None
@export var timestep: float = 0.005
@export var gravity: float = 5.0 
@export var softening: float = 5
@export_range(0.0, 100.0, 1.0) var binding_radius: float = 0.0
@export_range(0.0, 1.0, 0.0001) var binding_strength: float = 0.01
