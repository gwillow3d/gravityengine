extends Label

@export var simulation: Simulation

func _ready() -> void:
	if simulation:
		simulation.population_changed.connect(_update_population)

func _update_population(count: int) -> void:
	text = "Particles: %s / %s" % [count, Simulation.MAX_PARTICLES]
