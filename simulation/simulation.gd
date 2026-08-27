@abstract
class_name Simulation
extends Node

# Signals #
signal simulation_ready
signal world_size_changed(world_size: Vector2i)
signal border_type_changed(border_type: BorderType)
signal gravity_changed(strength: float)
signal population_changed(population: int)
signal energy_updated(kinetic: float, potential: float, linear_momentum: Vector2, angular_momentum: float)
signal simulation_reset

var _p_positions: PackedVector2Array
var _p_velocities: PackedVector2Array
var _p_masses: PackedFloat32Array

# Exports #
@export var config: SimulationConfig

# Functionality #

@abstract
func setup() 

@abstract
func step(steps: int) 

@abstract
func reset(config: SimulationConfig) 

# Conservation #

func compute_total_linear_momentum() -> Vector2:
	var momentum = Vector2.ZERO
	
	for i in range(0, get_particle_count()):
		var v = _p_velocities[i]
		var m = _p_masses[i]
		momentum += v * m
	
	return momentum

func compute_total_angular_momentum() -> float:
	var momentum := 0.0
	
	for i in range(0, get_particle_count()):
		var pos = _p_positions[i]
		var vel = _p_velocities[i]
		var mass = _p_masses[i]
		var centre = config.world_size / 2.0
		var r = pos - centre
		
		momentum += mass * (r.x * vel.y - r.y * vel.x)
	return momentum

# Getters & Setters #

func get_particle_count() -> int:
	return _p_positions.size()

func get_particle_position(index: int) -> Vector2:
	return _p_positions[index]

func get_particle_mass(index: int) -> float:
	return _p_masses[index]

func get_border_mode() -> BorderType:
	return config.border_type

# Enums #
enum BorderType {
	## There is no border, particles can travel endlessly in any direction.
	None,
	## The border acts as a hard wall.
	## Violates conservation of energy.
	Stop,
	## The border will reflect particles, inverting their momentum.
	Bounce,
	## Particles will pass through the border to the opposite side.
	## Also allows gravity to wrap around.
	Wraparound
}
