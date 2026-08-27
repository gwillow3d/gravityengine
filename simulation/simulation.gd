@abstract
class_name ISimulation
extends Node

# Signals #
signal simulation_ready
signal world_size_changed(world_size: Vector2i)
signal border_type_changed(border_type: BorderType)
signal gravity_changed(strength: float)
signal population_changed(population: int)
signal energy_updated(kinetic: float, potential: float, linear_momentum: Vector2, angular_momentum: float)
signal simulation_reset

# Exports #
@export_category("Simulation")
@export var world_size: Vector2i = Vector2i(500, 500)
@export var generator: Generator = null
@export var border_type: BorderType = BorderType.None
@export var timestep: float = 0.005

@export_category("Forces")
@export var gravity: float = 5.0 
@export var softening: float = 5
@export_range(0.0, 100.0, 1.0) var binding_radius: float = 0.0
@export_range(0.0, 1.0, 0.0001) var binding_strength: float = 0.01

# Functionality #

@abstract
func setup() 

@abstract
func step(steps: int) 

@abstract
func reset() 

# Conservation #

@abstract
func compute_total_linear_momentum() -> Vector2

@abstract
func compute_total_angular_momentum() -> float

# Getters & Setters #

@abstract
func get_particle_count() -> int

@abstract
func get_particle_position(index: int) -> Vector2

@abstract
func get_particle_mass(index: int) -> float

@abstract
func get_border_mode() -> BorderType


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
