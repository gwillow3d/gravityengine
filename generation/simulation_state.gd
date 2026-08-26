class_name SimulationState
extends Resource

var positions: PackedVector2Array = []
var velocities: PackedVector2Array = []
var masses: PackedFloat32Array = []

func add_particle(position: Vector2, velocity: Vector2, mass: float) -> void:
	positions.append(position)
	velocities.append(velocity)
	masses.append(mass)
