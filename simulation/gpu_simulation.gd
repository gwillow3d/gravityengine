class_name GPUSimulation
extends Resource

const MAX_PARTICLES = 8192

var _positions: PackedVector2Array
var _velocities: PackedVector2Array
var _accelerations: PackedVector2Array
var _masses: PackedFloat32Array

var simulation_viewport: SubViewport
var simulation_data: TextureRect

func setup(config: SimulationConfig) -> void:
	var image = Image.create_empty(MAX_PARTICLES * 2, 1, false, Image.Format.FORMAT_RGBAF)
	simulation_data.texture = ImageTexture.create_from_image(image)
	simulation_viewport.size = Vector2(MAX_PARTICLES * 2, 1)

func step(steps: int, config: SimulationConfig) -> void:
	_unpack()
	_pack()
	
func _unpack() -> void:
	var image = simulation_data.texture.get_image()
	
	for i in range(0, _positions.size()):
		var color_a = image.get_pixel(i * 2, 0)
		var color_b = image.get_pixel(i * 2, 0)
		
		_positions[i] = Vector2(color_a.r, color_a.g)
		_velocities[i] = Vector2(color_a.b, color_a.a)
		_accelerations[i] = Vector2(color_b.r, color_b.g)
		_masses[i] = color_b.b

func _pack() -> void:
	var image = Image.create_empty(MAX_PARTICLES * 2, 1, false, Image.Format.FORMAT_RGBAF)
	
	for i in range(0, _positions.size()):
		var pos = _positions[i]
		var vel = _velocities[i]
		var acc = _accelerations[i]
		var mass = _masses[i]
		
		image.set_pixel(i * 2, 0, Color(pos.x, pos.y, vel.x, vel.y))
		image.set_pixel(i * 2 + 1, 0, Color(acc.x, acc.y, mass, 0.0))
	
	simulation_data.texture = ImageTexture.create_from_image(image)

func set_state(positions: PackedVector2Array, velocities: PackedVector2Array, masses: PackedFloat32Array) -> void:
	_positions = positions
	_velocities = velocities
	_masses = masses
	
	_accelerations = PackedVector2Array()
	_accelerations.resize(_positions.size())
	
	_pack()

func get_potential_energy() -> float:
	return 0

func get_positions() -> PackedVector2Array:
	return _positions

func get_velocities() -> PackedVector2Array:
	return _velocities
