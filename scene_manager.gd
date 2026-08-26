class_name SceneManager
extends Node

@export var simulation: Simulation
@export var color_manager: SimulationColorManager

func _ready() -> void:
	# SIGNALS #
	simulation.simulation_reset.connect(color_manager._on_simulation_reset)
