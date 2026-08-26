class_name LatticeGenerator
extends Generator

@export var spacing: float = 100.0
@export_range(0.0, 1.0) var max_dispacement: float = 0.0

func generate(gravity: float, world_size: Vector2i) -> SimulationState:
	var state = SimulationState.new()
	
	var rows = world_size.x / spacing
	var columns = world_size.y / spacing
	
	for x in range(0, rows):
		for y in range(0, columns):
			var precise_pos = Vector2(x * spacing, y * spacing) + Vector2(spacing / 2, spacing / 2)
			var angle = randf_range(0.0, TAU)
			var dist = randf_range(0.0, spacing * max_dispacement)
			var pos = precise_pos + Vector2(cos(angle), sin(angle)) * dist
			var vel = Vector2.ZERO
			var mass = randf_range(min_initial_mass, max_initial_mass)
			state.add_particle(pos, vel, mass)
	
	return state

func get_id() -> String:
	return "lattice"
