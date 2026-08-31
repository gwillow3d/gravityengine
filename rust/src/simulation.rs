use godot::prelude::*;

const MAX_PARTICLES: i32 = 1024;

#[derive(GodotClass)]
#[class(init, base=Resource)]
struct FastCPUSimulation {
    positions: PackedVector2Array,
    velocities: PackedVector2Array,
    accelerations: PackedVector2Array,
    masses: PackedFloat32Array,

    potential_energy: f32,

    base: Base<Resource>
}

#[godot_api]
impl FastCPUSimulation {
    #[func]
    fn set_state(&mut self, positions: PackedVector2Array, velocities: PackedVector2Array, masses: PackedFloat32Array) {
        self.positions = positions;
        self.velocities = velocities;
        self.masses = masses;
        
        self.accelerations = PackedVector2Array::new();
        self.accelerations.resize(self.positions.len())
    }

    #[func]
    fn get_potential_energy(&self) -> f32 {
        self.potential_energy
    }

    #[func]
    fn get_positions(&self) -> PackedVector2Array {
        self.positions.clone()
    }

    #[func]
    fn get_velocities(&self) -> PackedVector2Array {
        self.velocities.clone()
    }
}