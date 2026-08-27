class_name ISimulation
extends Node

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
