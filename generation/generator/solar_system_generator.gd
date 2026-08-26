class_name SolarSystemGenerator
extends Generator

@export var min_star_mass: float = 7500
@export var max_star_mass: float = 35000
@export var max_planet_count: int = 8
@export_range(0, 2) var max_asteroid_belt_count: int = 2
## Percentage of the "population" that will be positioned in completely random orbits.
## Remaining particles will be used to populate the asteroid belts
@export_range(0.0, 1.0) var random_particle_ratio: float = 0.02
@export var gas_giant_size: float = 4.0

var debug_state: InitialSolarSystemState

func generate(gravity: float, world_size: Vector2i) -> SimulationState:
	var dbg = InitialSolarSystemState.new()
	
	print("[WorldGen] Generating Solar System")
	var state = SimulationState.new()
	var center = world_size / 2.0
	var star_pos = center
	var star_mass = randf_range(min_star_mass, max_star_mass)
	print("[WorldGen] Star mass is %.1f" % star_mass)
	
	dbg.star_position = star_pos
	dbg.star_mass = star_mass
	
	state.add_particle(star_pos, Vector2.ZERO, star_mass)
	
	var star_radius = sqrt(star_mass)
	
	var planet_count = randi_range(1, max_planet_count)
	
	var orbital_positions = planet_count
	var innermost_orbit = star_radius * 3
	var outermost_orbit = star_radius * 150
	var are_orbits_retrograde = randf() > 0.5
	
	var random_particles = int(population * random_particle_ratio)
 	
	var planetary_mass = 0.0
	var asteroid_mass = 0.0
	
	print("[WorldGen] Generating system with %s planets and %s asteroids" % [planet_count, random_particles])
	print("[WorldGen] Are orbits retrograde is %s" % are_orbits_retrograde)
	
	for i in range(0, orbital_positions):
		var distance = _create_reasonable_orbit_distance(i, orbital_positions, innermost_orbit, outermost_orbit, 0.1)
		var distance_factor = (i + 1.0) / orbital_positions
		
		# probability is never 100%
		var is_gas_giant: bool = randf() < distance_factor * 0.85
		var falloff = pow(distance_factor, 0.3)
		var min_mass = star_mass * 0.001 * falloff
		var max_mass = star_mass * 0.01 * falloff
		var mass = randf_range(min_mass, max_mass)
		if is_gas_giant: mass *= gas_giant_size
		
		var angle = randf_range(0.0, TAU)
		var pos = center + Vector2(cos(angle), sin(angle)) * distance
		var velocity = _create_orbital_velocity(gravity, pos, star_pos, star_mass, are_orbits_retrograde)
		state.add_particle(pos, velocity, mass)
		planetary_mass += mass
		if is_gas_giant:
			print("[WorldGen] Created a Gas Giant at index %s with mass of %.1f and distance of %.1f" % [i, mass, distance])
		else:
			print("[WorldGen] Created Planet at index %s with mass of %.1f and distance of %.1f" % [i, mass, distance])
		
		dbg.orbit_index_distances.append(distance)
		dbg.planet_positions.append(pos)
		dbg.planet_masses.append(mass)
	
	for i in range(0, int(random_particles)):
		var angle = randf_range(0.0, TAU)
		var dist = sqrt(randf_range(innermost_orbit * innermost_orbit, outermost_orbit * outermost_orbit))
		var pos = center + Vector2(cos(angle), sin(angle)) * dist
		var vel = _create_orbital_velocity(gravity, pos, star_pos, star_mass, are_orbits_retrograde)
		var mass = randf_range(min_initial_mass, max_initial_mass)
		state.add_particle(pos, vel, mass)
		asteroid_mass += mass
	
	var cm_total = star_mass + planetary_mass + asteroid_mass
	var cm_star = star_mass / cm_total * 100
	var cm_planets = planetary_mass / cm_total * 100
	var cm_asteroids = asteroid_mass / cm_total * 100
	
	print("[WorldGen] Created %s random particles" % int(random_particles))
	print("[WorldGen] Solar System generation complete!")
	print("[WorldGen] Mass composition is: %.1f%% star, %.1f%% planets, %.1f%% asteroids" % [cm_star, cm_planets, cm_asteroids])
	
	dbg.orbit_index_count = dbg.orbit_index_distances.size()
	debug_state = dbg
	
	return state

func _create_reasonable_orbit_distance(index: int, total_slots: int, min_dist: float, max_dist: float, variability: float) -> float:
	var distance_per_slot = (max_dist - min_dist) / total_slots
	var variation = 1 + variability * ((randf() - 0.5) * 2)
	return min_dist + (distance_per_slot * index) * variation

func _create_orbital_velocity(gravity: float, child_position: Vector2, parent_position: Vector2, parent_mass: float, is_retrograde: bool = false) -> Vector2:
	var rel_pos = child_position - parent_position
	var r = rel_pos.length()
	var r_vec = rel_pos / r
	var r_tan = Vector2(-r_vec.y, r_vec.x)
	
	var orbital_speed = sqrt(gravity * parent_mass / r)
	if is_retrograde:
		orbital_speed *= -1
	return orbital_speed * r_tan

func get_id() -> String:
	return "solar_system"

class InitialSolarSystemState:
	var orbit_index_count: int
	var star_position: Vector2
	var star_mass: float
	var orbit_index_distances: Array[float]
	var planet_positions: Array[Vector2]
	var planet_masses: Array[float]
