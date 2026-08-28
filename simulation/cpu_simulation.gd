class_name CPUSimulation
extends Simulation

# Private fields #
const MAX_PARTICLES = 128

var _p_accelerations: PackedVector2Array

var _kinetic_energy: float
var _potential_energy: float

func setup() -> void:
	simulation_ready.emit()
	
	world_size_changed.emit(config.world_size)
	border_type_changed.emit(config.border_type)
	gravity_changed.emit(config.gravity)

# Public functions
func step(steps: int) -> void:
	_kinetic_energy = 0.0
	_potential_energy = 0.0
	
	for step in steps:
		_half_kick()
		_drift()
		_accelerate()
		_half_kick()
	
	_update_kinetic_energy()
	
	energy_updated.emit(_kinetic_energy, _potential_energy, compute_total_linear_momentum(), compute_total_angular_momentum())

func reset(_config: SimulationConfig) -> void:
	_p_positions.clear()
	_p_velocities.clear()
	_p_accelerations.clear()
	_p_masses.clear()
	
	config = _config
	
	if config.generator:
		var state = config.generator.generate(config.gravity, config.world_size)
		
		_apply_state(state)
		_remove_drift()
	
	simulation_reset.emit()
	
	world_size_changed.emit(config.world_size)
	border_type_changed.emit(config.border_type)
	gravity_changed.emit(config.gravity)

# Private functions #
func _apply_state(state: SimulationState) -> void:
	_p_positions = state.positions.duplicate()
	_p_velocities = state.velocities.duplicate()
	_p_accelerations = PackedVector2Array()
	_p_accelerations.resize(_p_positions.size())
	_p_masses = state.masses.duplicate()
	population_changed.emit(get_particle_count())

func _remove_drift() -> void:
	var weighted_velocites: Vector2 = Vector2.ZERO
	var total_mass: float = 0.0
	var particle_count = get_particle_count()
	for i in range(0, particle_count):
		var m = abs(_p_masses[i])
		weighted_velocites += _p_velocities[i] * m
		total_mass += m
	
	var mean_drift = weighted_velocites / total_mass
	
	for i in range(0, particle_count):
		_p_velocities[i] -= mean_drift

func _half_kick() -> void:
	for i in range(0, get_particle_count()):
		_p_velocities[i] += _p_accelerations[i] * config.timestep * 0.5

func _drift() -> void:
	for i in range(0, get_particle_count()):
		_p_positions[i] += _p_velocities[i] * config.timestep
		_constrain(i)
		_p_accelerations[i] = Vector2.ZERO

func _constrain(i: int) -> void:
	var w: float = config.world_size.x
	var h: float = config.world_size.y
	var x = _p_positions[i].x
	var y = _p_positions[i].y
		
	match config.border_type:
			BorderType.Wraparound:
				_p_positions[i].x = fmod(fmod(x, w) + w, w)
				_p_positions[i].y = fmod(fmod(y, h) + h, h)
			BorderType.Stop:
				var old_x = x
				var old_y = y
				_p_positions[i].x = clampf(x, 0, config.world_size.x)
				_p_positions[i].y = clampf(y, 0, config.world_size.y)
				if _p_positions[i].x != old_x:
					_p_velocities[i].x = 0.0
				if _p_positions[i].y != old_y:
					_p_velocities[i].y = 0.0
			BorderType.Bounce:
				if x < 0 or x > config.world_size.x:
					var offset = (-x if x < 0 else config.world_size.x - x) * 2
					_p_positions[i].x += offset
					_p_velocities[i].x *= -1
				if y < 0 or y > config.world_size.y:
					var offset = (-y if y < 0 else config.world_size.y - y) * 2
					_p_positions[i].y += offset
					_p_velocities[i].y *= -1

func _accelerate() -> void:
	var particle_count = get_particle_count()
	var half_size = config.world_size / 2.0
	for i in range(0, particle_count):
		var p1 = _p_positions[i]
		var m1 = _p_masses[i]
		for j in range(i + 1, particle_count):
			var p2 = _p_positions[j]
			var m2 = _p_masses[j]
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
			
			_p_accelerations[i] += acc * m2
			_p_accelerations[j] -= acc * m1
			_potential_energy -= config.gravity * m1 * m2 / r

func _update_kinetic_energy() -> void:
	for i in range(0, get_particle_count()):
		var m1 = _p_masses[i]
		var vel = _p_velocities[i].length()
		_kinetic_energy += 0.5 * m1 * (vel*vel)

func add_particle(position: Vector2, velocity: Vector2, mass: float) -> void:
	_p_positions.append(position)
	_p_velocities.append(velocity)
	_p_accelerations.append(Vector2.ZERO)
	_p_masses.append(mass)
	population_changed.emit(_p_positions.size())

# Getters and setters #

func set_gravity(strength: float) -> void:
	config.gravity = strength
	gravity_changed.emit(config.gravity)
