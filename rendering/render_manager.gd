class_name RenderManager
extends Node

@export var particle_renderer: MultiMeshInstance2D
@export var background_renderer: MultiMeshInstance2D

@export var particle_multimesh: MultiMesh
@export var background_multimesh: MultiMesh

@export var size_multiplier: float = 1.0
@export var black_hole_threshold: int = 500000
@export var glow_size_multiplier: int = 75
@export_range(0.0, 1.0) var minimum_significance: float = 0.09

var _simulation: Simulation

func setup(simulation: Simulation) -> void:
	_simulation = simulation

func _ready() -> void:
	particle_multimesh.use_colors = true
	background_multimesh.use_colors = true

func _process(_delta: float) -> void:
	for i in range(_simulation.get_particle_count()):
		var m = _simulation.get_particle_mass(i)
		var r = sqrt(m) * size_multiplier
		var c = Color.WHITE
		if m > black_hole_threshold:
			r *= 0.01
			c = Color.BLACK
		var t = Transform2D(0.0, Vector2(r, r), 0.0, _simulation.get_particle_position(i))
		multimesh.set_instance_transform_2d(i, t)
		multimesh.set_instance_color(i, c)
		
		var t2 = Transform2D(0.0, Vector2(r, r), 0.0, _simulation.get_particle_position(i))
		multimesh.set_instance_transform_2d(i, t)

func _on_population_changed(population: int) -> void:
	particle_multimesh.instance_count = population
	background_multimesh.instance_count = population
