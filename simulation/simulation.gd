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

var config: SimulationConfig

var _p_positions: PackedVector2Array
var _p_velocities: PackedVector2Array
var _p_masses: PackedFloat32Array

var _kinetic_energy: float
var _potential_energy: float

# Functionality #

func step(steps: int):
	_kinetic_energy = 0.0
	_potential_energy = 0.0
	
	istep(steps)
	
	_update_kinetic_energy()
	
	energy_updated.emit(_kinetic_energy, _potential_energy, compute_total_linear_momentum(), compute_total_angular_momentum())

@abstract
func setup() 

@abstract
func istep(steps: int) 

@abstract
func reset(config: SimulationConfig) 

func _remove_drift() -> void:
	var weighted_velocites: Vector2 = Vector2.ZERO
	var total_mass: float = 0.0
	var particle_count = get_particle_count()
	for i in range(0, particle_count):
		var m = abs(_p_masses[i])
		weighted_velocites += _p_velocities[i] * m
		total_mass += m
	
	var mean_drift = weighted_velocites / total_mass
	
	for i in range(0, particle_count):
		_p_velocities[i] -= mean_drift

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

func _update_kinetic_energy() -> void:
	for i in range(0, get_particle_count()):
		var m1 = _p_masses[i]
		var vel = _p_velocities[i].length()
		_kinetic_energy += 0.5 * m1 * (vel*vel)

# Getters & Setters #

func get_particle_count() -> int:
	return _p_positions.size()

func get_particle_position(index: int) -> Vector2:
	return _p_positions[index]

func get_particle_velocity(index: int) -> Vector2:
	return _p_velocities[index]

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
