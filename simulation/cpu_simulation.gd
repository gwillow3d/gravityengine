class_name CPUSimulation
extends Simulation

# Private fields #
const MAX_PARTICLES = 128

var _positions: PackedVector2Array
var _velocities: PackedVector2Array
var _accelerations: PackedVector2Array
var _masses: PackedFloat32Array

var _potential_energy: float

func setup(config: SimulationConfig) -> void:
	pass

# Public functions
func istep(steps: int, config: SimulationConfig) -> void:
	_potential_energy = 0.0
	
	for step in steps:
		_half_kick(config)
		_drift(config)
		_accelerate(config)
		_half_kick(config)

# Private functions #

func _half_kick(config: SimulationConfig) -> void:
	for i in range(0, get_particle_count()):
		_velocities[i] += _accelerations[i] * config.timestep * 0.5

func _drift(config: SimulationConfig) -> void:
	for i in range(0, get_particle_count()):
		_positions[i] += _velocities[i] * config.timestep
		_constrain(i, config)
		_accelerations[i] = Vector2.ZERO

func _constrain(i: int, config: SimulationConfig) -> void:
	var w: float = config.world_size.x
	var h: float = config.world_size.y
	var x = _positions[i].x
	var y = _positions[i].y
		
	match config.border_type:
			BorderType.Wraparound:
				_positions[i].x = fmod(fmod(x, w) + w, w)
				_positions[i].y = fmod(fmod(y, h) + h, h)
			BorderType.Stop:
				var old_x = x
				var old_y = y
				_positions[i].x = clampf(x, 0, config.world_size.x)
				_positions[i].y = clampf(y, 0, config.world_size.y)
				if _positions[i].x != old_x:
					_velocities[i].x = 0.0
				if _positions[i].y != old_y:
					_velocities[i].y = 0.0
			BorderType.Bounce:
				if x < 0 or x > config.world_size.x:
					var offset = (-x if x < 0 else config.world_size.x - x) * 2
					_positions[i].x += offset
					_velocities[i].x *= -1
				if y < 0 or y > config.world_size.y:
					var offset = (-y if y < 0 else config.world_size.y - y) * 2
					_positions[i].y += offset
					_velocities[i].y *= -1

func _accelerate(config: SimulationConfig) -> void:
	var particle_count = get_particle_count()
	var half_size = config.world_size / 2.0
	for i in range(0, particle_count):
		var p1 = _positions[i]
		var m1 = _masses[i]
		for j in range(i + 1, particle_count):
			var p2 = _positions[j]
			var m2 = _masses[j]
			var d = p2 - p1
			if config.border_type == BorderType.Wraparound:
				if d.x >  half_size.x: d.x -= config.world_size.x
				if d.x < -half_size.x: d.x += config.world_size.x
				if d.y >  half_size.y: d.y -= config.world_size.y
				if d.y < -half_size.y: d.y += config.world_size.y
			
			var dist = d.length()
			var r = sqrt(dist * dist + config.softening * config.softening);
			
			var acc = config.gravity / (r * r * r) * d
			
			#if dist < config.binding_radius and sign(m1) == sign(m2):
			#	var total_mass = m1 + m2
			#	var i_dom = m1 / total_mass
			#	var j_dom = m2 / total_mass
			#	
			#	var iv = _p_velocities[i]
			#	var jv = _p_velocities[j]
			#	var v_com = (iv * m1 + jv * m2) / total_mass
			#	
			#	var strength = config.binding_strength * (1 - dist / config.binding_radius)
			#	
			#	_p_velocities[i] = iv.lerp(v_com, strength * j_dom)
			#	_p_velocities[j] = jv.lerp(v_com, strength * i_dom)
			
			_accelerations[i] += acc * m2
			_accelerations[j] -= acc * m1
			_potential_energy -= config.gravity * m1 * m2 / r

func set_state(positions: PackedVector2Array, velocities: PackedVector2Array, masses: PackedFloat32Array) -> void:
	_positions = positions
	_velocities = velocities
	_masses = masses
	
	_accelerations = PackedVector2Array()
	_accelerations.resize(_positions.size())

func get_potential_energy() -> float:
	return _potential_energy

func get_positions() -> PackedVector2Array:
	return _positions

func get_velocities() -> PackedVector2Array:
	return _velocities
