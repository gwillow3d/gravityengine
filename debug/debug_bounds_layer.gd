extends Node2D

@onready var simulation: Simulation = $"../../GPUSimulation"

func _ready() -> void:
	simulation.simulation_reset.connect(queue_redraw)

func _draw() -> void:
	var camera_bounds = Vector2.ZERO
	
	match simulation.border_type:
		Simulation.BorderType.Wraparound:
			camera_bounds = simulation.world_size
		Simulation.BorderType.Bounce, Simulation.BorderType.Stop:
			camera_bounds = simulation.world_size * 2
	
	if simulation.border_type != Simulation.BorderType.None:
		draw_rect(Rect2(0, 0, camera_bounds.x, camera_bounds.y), Color.WHITE, false)
