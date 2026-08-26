class_name ProtoplanetaryDiskGenerator
extends Generator

@export var star_mass: float = 1000
@export var min_orbit_distance: float = 75
@export var max_orbit_distance: float = 225

# Reduces the orbital velocity of particles by this factor, causing them to spiral inward
@export var spiral_factor: float = 0.0

func generate(gravity: float, world_size: Vector2i) -> SimulationState:
	var state = SimulationState.new()
	var center = world_size / 2.0
	var star_pos = center
	
	state.add_particle(star_pos, Vector2.ZERO, star_mass)
	
	var star_radius = sqrt(star_mass)
	if star_mass > 500000:
		star_radius *= 0.01
	
	var min_dist = star_radius + min_orbit_distance
	var max_dist = star_radius + max_orbit_distance
	
	for i in range(0, population):
		var angle = randf_range(0.0, TAU)
		var dist = sqrt(randf_range(min_dist * min_dist, max_dist * max_dist))
		var pos = center + Vector2(cos(angle), sin(angle)) * dist
		var vel = _create_orbital_velocity(gravity, pos, star_pos, star_mass)
		vel = vel * (1 - spiral_factor)
		var mass = randf_range(min_initial_mass, max_initial_mass)
		state.add_particle(pos, vel, mass)
	
	return state

func _create_orbital_velocity(gravity: float, child_position: Vector2, parent_position: Vector2, parent_mass: float) -> Vector2:
	var rel_pos = child_position - parent_position
	var r = rel_pos.length()
	var r_vec = rel_pos / r
	var r_tan = Vector2(-r_vec.y, r_vec.x)
	
	var orbital_speed = sqrt(gravity * parent_mass / r)
	return orbital_speed * r_tan

func get_id() -> String:
	return "protoplanetary_disk"
