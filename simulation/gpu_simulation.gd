class_name GPUSimulation
extends Simulation

# Private fields #
const MAX_PARTICLES = 8192
const WORKGROUP_SIZE = 256
const POSITION_BYTE_OFFSET = 0
const PARTICLE_SIZE_BYTES = 32

var _is_ready := false

var _potential_energy: float

var _rd: RenderingDevice

var _accelerate_shader: RID
var _accelerate_pipeline: RID
var _accelerate_set: RID

var _kick_shader: RID
var _kick_pipeline: RID
var _kick_set: RID

var _drift_shader: RID
var _drift_pipeline: RID
var _drift_set: RID

var _constrain_shader: RID
var _constrain_pipeline: RID
var _constrain_set: RID

var _buffer: RID
var _gpe_buffer: RID
var _geometry_buffer: RID

var _has_submitted := false
var _state_update_needed := false

func setup() -> void:
	if OS.get_name() == "Web":
		printerr("Cannot run GPU simulation on WebGL!")
		return
	_setup_shaders()
	_is_ready = true
	simulation_ready.emit()
	
	world_size_changed.emit(config.world_size)
	border_type_changed.emit(config.border_type)
	gravity_changed.emit(config.gravity)

func _setup_shaders() -> void:
	_rd = RenderingServer.create_local_rendering_device()
	
	var input_bytes = PackedByteArray()
	input_bytes.resize(MAX_PARTICLES * PARTICLE_SIZE_BYTES)
	_buffer = _rd.storage_buffer_create(input_bytes.size(), input_bytes)
	
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0
	uniform.add_id(_buffer)
	
	var geometry_input_bytes = PackedByteArray()
	geometry_input_bytes.resize(12)
	geometry_input_bytes.encode_float(0, config.world_size.x)
	geometry_input_bytes.encode_float(4, config.world_size.y)
	geometry_input_bytes.encode_s32(8, config.border_type)
	_geometry_buffer = _rd.storage_buffer_create(geometry_input_bytes.size(), geometry_input_bytes)
	
	var geometry_uniform := RDUniform.new()
	geometry_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	geometry_uniform.binding = 1
	geometry_uniform.add_id(_geometry_buffer)
	
	var gpe_input_bytes = PackedByteArray()
	gpe_input_bytes.resize(MAX_PARTICLES * 4)
	_gpe_buffer = _rd.storage_buffer_create(gpe_input_bytes.size(), gpe_input_bytes)
	
	var gpe_uniform := RDUniform.new()
	gpe_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	gpe_uniform.binding = 2
	gpe_uniform.add_id(_gpe_buffer)
	
	_accelerate_shader = _rd.shader_create_from_spirv(load("res://shader/compute/accelerate.glsl").get_spirv())
	_accelerate_set = _rd.uniform_set_create([uniform, geometry_uniform, gpe_uniform], _accelerate_shader, 0)
	_accelerate_pipeline = _rd.compute_pipeline_create(_accelerate_shader)
	
	_kick_shader = _rd.shader_create_from_spirv(load("res://shader/compute/kick.glsl").get_spirv())
	_kick_set = _rd.uniform_set_create([uniform], _kick_shader, 0)
	_kick_pipeline = _rd.compute_pipeline_create(_kick_shader)

	_drift_shader = _rd.shader_create_from_spirv(load("res://shader/compute/drift.glsl").get_spirv())
	_drift_set = _rd.uniform_set_create([uniform], _drift_shader, 0)
	_drift_pipeline = _rd.compute_pipeline_create(_drift_shader)
	
	_constrain_shader = _rd.shader_create_from_spirv(load("res://shader/compute/constrain.glsl").get_spirv())
	_constrain_set = _rd.uniform_set_create([uniform, geometry_uniform], _constrain_shader, 0)
	_constrain_pipeline = _rd.compute_pipeline_create(_constrain_shader)

# Public functions
func istep(steps: int) -> void:
	if !_is_ready:
		return
	
	_potential_energy = 0.0
	
	if steps > 0:
		_gpu_process(config.timestep, steps)

func reset(_config: SimulationConfig) -> void:
	_p_positions.clear()
	_p_velocities.clear()
	_p_masses.clear()
	
	config = _config
	
	if config.generator:
		var state = config.generator.generate(config.gravity, config.world_size)
		_apply_state(state)
	
	simulation_reset.emit()
	
	world_size_changed.emit(config.world_size)
	border_type_changed.emit(config.border_type)
	gravity_changed.emit(config.gravity)

# Private functions #
func _apply_state(state: SimulationState) -> void:
	_p_positions = state.positions.duplicate()
	_p_velocities = state.velocities.duplicate()
	_p_masses = state.masses.duplicate()
	population_changed.emit(get_particle_count())
	
	_remove_drift()
	
	_state_update_needed = true

func _gpu_process(delta: float, steps: int) -> void:
	if _state_update_needed:
		if _has_submitted:
			_rd.sync()
		var input_bytes = _pack_particles()
		_rd.buffer_update(_buffer, 0, input_bytes.size(), input_bytes)
		_state_update_needed = false
	elif _has_submitted:
		_rd.sync()
		var bytes = _rd.buffer_get_data(_buffer)
		var gpe_bytes = _rd.buffer_get_data(_gpe_buffer)
		_unpack_particles(bytes)
		_potential_energy = _unpack_potential_energy(gpe_bytes)
		_has_submitted = false
	
	if _p_positions.size() == 0:
		return
	
	var n = _p_positions.size()
	var groups = int(ceil(float(n) / WORKGROUP_SIZE))
	var constants := PackedByteArray()
	constants.append_array(PackedFloat32Array([config.gravity, config.softening, delta]).to_byte_array())
	constants.resize(16)
	constants.encode_u32(12, n)
	
	var compute_list := _rd.compute_list_begin()
	
	for i in range(0, steps):
		# half-kick
		_rd.compute_list_bind_compute_pipeline(compute_list, _kick_pipeline)
		_rd.compute_list_bind_uniform_set(compute_list, _kick_set, 0)
		_rd.compute_list_set_push_constant(compute_list, constants, constants.size())
		_rd.compute_list_dispatch(compute_list, groups, 1, 1)
		_rd.compute_list_add_barrier(compute_list)
		
		# drift
		_rd.compute_list_bind_compute_pipeline(compute_list, _drift_pipeline)
		_rd.compute_list_bind_uniform_set(compute_list, _drift_set, 0)
		_rd.compute_list_set_push_constant(compute_list, constants, constants.size())
		_rd.compute_list_dispatch(compute_list, groups, 1, 1)
		_rd.compute_list_add_barrier(compute_list)
		
		# constrain
		_rd.compute_list_bind_compute_pipeline(compute_list, _constrain_pipeline)
		_rd.compute_list_bind_uniform_set(compute_list, _constrain_set, 0)
		_rd.compute_list_set_push_constant(compute_list, constants, constants.size())
		_rd.compute_list_dispatch(compute_list, groups, 1, 1)
		_rd.compute_list_add_barrier(compute_list)
		
		# accelerate
		_rd.compute_list_bind_compute_pipeline(compute_list, _accelerate_pipeline)
		_rd.compute_list_bind_uniform_set(compute_list, _accelerate_set, 0)
		_rd.compute_list_set_push_constant(compute_list, constants, constants.size())
		_rd.compute_list_dispatch(compute_list, groups, 1, 1)
		_rd.compute_list_add_barrier(compute_list)
		
		# half-kick
		_rd.compute_list_bind_compute_pipeline(compute_list, _kick_pipeline)
		_rd.compute_list_bind_uniform_set(compute_list, _kick_set, 0)
		_rd.compute_list_set_push_constant(compute_list, constants, constants.size())
		_rd.compute_list_dispatch(compute_list, groups, 1, 1)
		if i != steps - 1:
			_rd.compute_list_add_barrier(compute_list)
	_rd.compute_list_end()
	
	_rd.submit()
	_has_submitted = true

func _pack_particles() -> PackedByteArray:
	var bytes := PackedByteArray()
	for i in range(0, _p_positions.size()):
		var pos_array = PackedFloat32Array([_p_positions[i].x, _p_positions[i].y])
		var acc_array = PackedFloat32Array()
		acc_array.resize(2)
		var vel_array = PackedFloat32Array([_p_velocities[i].x, _p_velocities[i].y])
		var mass_array = PackedFloat32Array([_p_masses[i], 0.0])
		bytes.append_array(pos_array.to_byte_array())
		bytes.append_array(acc_array.to_byte_array())
		bytes.append_array(vel_array.to_byte_array())
		bytes.append_array(mass_array.to_byte_array())
	return bytes

func _unpack_particles(bytes: PackedByteArray) -> void:
	for i in range(0, _p_positions.size()):
		var pos_x = bytes.decode_float(i * PARTICLE_SIZE_BYTES + POSITION_BYTE_OFFSET)
		var pos_y = bytes.decode_float(i * PARTICLE_SIZE_BYTES + POSITION_BYTE_OFFSET + 4)
		var vel_x = bytes.decode_float(i * PARTICLE_SIZE_BYTES + POSITION_BYTE_OFFSET + 16)
		var vel_y = bytes.decode_float(i * PARTICLE_SIZE_BYTES + POSITION_BYTE_OFFSET + 20)
		
		_p_positions[i].x = pos_x
		_p_positions[i].y = pos_y
		_p_velocities[i].x = vel_x
		_p_velocities[i].y = vel_y

func _unpack_potential_energy(bytes: PackedByteArray) -> float:
	var total := 0.0
	for i in range(0, get_particle_count()):
		total += bytes.decode_float(i * 4)
	return total

func get_potential_energy() -> float:
	return _potential_energy
