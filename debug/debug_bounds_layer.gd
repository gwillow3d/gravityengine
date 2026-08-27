class_name DebugBoundaryLayer
extends Node2D

var _world_size: Vector2
var _border_type: Simulation.BorderType

func _on_simulation_border_type_changed(border_type: Simulation.BorderType) -> void:
	_border_type = border_type
	queue_redraw()

func _on_simulation_size_changed(world_size: Vector2) -> void:
	_world_size = world_size
	queue_redraw()

func _draw() -> void:
	var boundary = Vector2.ZERO
	
	match _border_type:
		Simulation.BorderType.Wraparound:
			boundary = _world_size
		Simulation.BorderType.Bounce, Simulation.BorderType.Stop:
			boundary = _world_size * 2
	
	if _border_type != Simulation.BorderType.None:
		draw_rect(Rect2(0, 0, boundary.x, boundary.y), Color.WHITE, false)
