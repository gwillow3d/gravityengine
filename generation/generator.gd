@abstract
class_name Generator
extends Resource

@export var population: int = 100
@export var min_initial_mass: float = 1.0
@export var max_initial_mass: float = 2.0

@abstract
func generate(gravity: float, world_size: Vector2i) -> SimulationState

@abstract
func get_id() -> String
