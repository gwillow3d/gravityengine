class_name LinkedCamera
extends Camera2D

@export var controller: CameraController

func _ready() -> void:
	if controller:
		controller.camera_zoomed.connect(_on_camera_zoomed)
		controller.camera_moved.connect(_on_camera_moved)

func _on_camera_zoomed(new_zoom: Vector2) -> void:
	zoom = new_zoom

func _on_camera_moved(new_position: Vector2) -> void:
	position = new_position
