class_name RandomGenerator
extends Generator

@export var max_initial_velocity: float = 5.0
@export_range(0.0, 1.0) var negative_proportion: float = 0.0

func generate(_gravity: float, world_size: Vector2i) -> SimulationState:
	var state = SimulationState.new()
	var remaining_negatives = population * negative_proportion
	
	for i in range(0, population):
		var x = randf_range(0.0, world_size.x)
		var y = randf_range(0.0, world_size.y)
		var vx = randf_range(-max_initial_velocity, max_initial_velocity)
		var vy = randf_range(-max_initial_velocity, max_initial_velocity)
		var mass = randf_range(min_initial_mass, max_initial_mass)
		if remaining_negatives > 0:
			mass *= -1
			remaining_negatives -= 1
		state.add_particle(Vector2(x, y), Vector2(vx, vy), mass)
	
	return state

func get_id() -> String:
	return "random"
