class_name CameraController
extends Node2D

signal camera_zoomed(new_zoom: Vector2)
signal camera_moved(new_position: Vector2)

@export var min_zoom: float = 0.01
@export var max_zoom: float = 25.0

var _position: Vector2
var _zoom: float = 1.0

var _border_type: Simulation.BorderType
var _world_size: Vector2i

func _ready() -> void:
	await get_tree().process_frame
	_position = _world_size / 2.0
	camera_moved.emit(_position)

func _process(delta: float) -> void:
	var vector = Input.get_vector("camera_move_left", "camera_move_right", "camera_move_up", "camera_move_down")
	if vector.length_squared() > 0:
		vector = vector.normalized()
	_position += vector * delta * 1000
	
	var camera_bounds = Vector2.ZERO
	
	match _border_type:
		Simulation.BorderType.Wraparound:
			camera_bounds = _world_size
		Simulation.BorderType.Bounce, Simulation.BorderType.Stop:
			camera_bounds = _world_size * 2
	
	if _border_type != Simulation.BorderType.None:
		_position.x = fposmod(_position.x, camera_bounds.x)
		_position.y = fposmod(_position.y, camera_bounds.y)
	camera_moved.emit(_position)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom *= 1.1
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom *= 0.9
			_zoom = clampf(_zoom, min_zoom, max_zoom)
			camera_zoomed.emit(Vector2(_zoom, _zoom))
	if event is InputEventKey:
		if event.is_action("camera_return_home"):
			_position = _world_size / 2.0
			camera_moved.emit(_position)

func _on_world_size_changed(world_size: Vector2i) -> void:
	_world_size = world_size

func _on_border_type_changed(border_type: Simulation.BorderType) -> void:
	_border_type = border_type
