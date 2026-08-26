extends Node2D

@export var viewports: Dictionary[SubViewport, float]

func _ready() -> void:
	_resize()
	get_viewport().size_changed.connect(_resize)

func _resize() -> void:
	var size = get_viewport().get_visible_rect().size
	for instance in viewports.keys():
		instance.size = size / viewports[instance]
