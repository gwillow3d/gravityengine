class_name BackgroundRenderer
extends MultiMeshInstance2D

const BLACK_HOLE_THRESHOLD = 500000

@onready var camera: Camera2D = $"../Camera2D"

@export var simulation: Simulation
@export var visualiser_type: VisualiserType = VisualiserType.MassDensity

var max_velocity: float = 0.0

enum VisualiserType {
	MassDensity,
	Velocity
}

func _ready() -> void:
	multimesh.use_colors = true
	simulation.population_changed.connect(_on_population_changed)

func _process(_delta: float) -> void:
	var zoom = camera.zoom.x
	var zoom_multiplier = lerp(5, 1, max(log(min(zoom, 1))+1, 0))
	
	match visualiser_type:
		VisualiserType.MassDensity:
			for i in range(simulation.get_particle_count()):
				var m = simulation.get_particle_mass(i)
				var r = sqrt(m) * 25
				if m > 500000:
					r *= 0.01
				var t = Transform2D(0.0, Vector2(r, r), 0.0, simulation.get_particle_position(i))
				multimesh.set_instance_transform_2d(i, t)
		VisualiserType.Velocity:
			for i in range(simulation.get_particle_count()):
				var m = simulation.get_particle_mass(i)
				var vl = simulation._p_velocities[i].length() / max_velocity
				var r = sqrt(m) * vl * 10 * zoom_multiplier
				var t = Transform2D(0.0, Vector2(r, r), 0.0, simulation.get_particle_position(i))
				multimesh.set_instance_transform_2d(i, t)

func _on_population_changed(population: int) -> void:
	var min_mass = 10000000
	var max_mass = 0
	
	multimesh.instance_count = population
	
	for i in range(simulation.get_particle_count()):
		var m = simulation.get_particle_mass(i)
		var v = simulation._p_velocities[i]
		if v.length() > max_velocity:
			max_velocity = v.length()
		
		if m >= BLACK_HOLE_THRESHOLD:
			continue # Prevent black hole from dominating the mass range
		if m < min_mass: min_mass = m
		if m > max_mass: max_mass = m
	
	var mass_range = max_mass - min_mass
	# If there is no dominant mass, make every mass have a low significance
	if mass_range < 1000:
		mass_range = 1000
	mass_range *= 2.5
	
	for i in range(simulation.get_particle_count()):
		var m = simulation.get_particle_mass(i)
		var significance = (m - min_mass) / mass_range
		if m > BLACK_HOLE_THRESHOLD:
			significance = 0.5
		
		multimesh.set_instance_color(i, Color(significance, 0.0, 0.0, 1.0))
