extends Node2D

@export var simulation: Simulation

func _ready() -> void:
	simulation.simulation_reset.connect(queue_redraw)

func _draw() -> void:
	if simulation.generator is SolarSystemGenerator:
		if simulation.generator.debug_state == null:
			return
		var state: SolarSystemGenerator.InitialSolarSystemState = simulation.generator.debug_state
		
		draw_circle(state.star_position, sqrt(state.star_mass), Color.YELLOW, false)
		
		for i in range(0, state.orbit_index_count):
			var r = state.orbit_index_distances[i]
			
			draw_circle(state.star_position, r, Color.BLUE, false)
		
		for i in range(0, state.planet_masses.size()):
			var r = sqrt(state.planet_masses[i])
			var p = state.planet_positions[i]
			
			draw_circle(p, r, Color.WEB_GREEN, false)
