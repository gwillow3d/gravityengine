use godot::prelude::*;

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
    fn setup(&self, config: Gd<Resource>) {}

    #[func]
    fn step(&mut self, steps: i32, config: Gd<Resource>) {
        self.potential_energy = 0.0;

        let timestep: f32 = config.get("timestep").to::<f32>();
        let softening: f32 = config.get("softening").to::<f32>();
        let gravity: f32 = config.get("gravity").to::<f32>();
        
        for _step in 0..steps {
            self._half_kick(timestep);
            self._drift(timestep);
            self._accelerate(softening, gravity);
            self._half_kick(timestep);
        }
    }

    fn _half_kick(&mut self, timestep: f32) {
        for i in 0..self.positions.len() {
            self.velocities[i] += self.accelerations[i] * timestep * 0.5;
        }
    }

    fn _drift(&mut self, timestep: f32) {
        for i in 0..self.positions.len() {
            self.positions[i] += self.velocities[i] * timestep;
            //_constrain(i, config)
            self.accelerations[i] = Vector2::ZERO;
        }
    }

    fn _accelerate(&mut self, softening: f32, gravity: f32) {
        let particle_count: i32 = self.positions.len() as i32;

        for i in 0..particle_count {
            let p1 = self.positions[i as usize];
            let m1 = self.masses[i as usize];
            for j in (i + 1)..particle_count {
                let p2 = self.positions[j as usize];
                let m2 = self.masses[j as usize];
                let d = p2 - p1;
                
                let dist = d.length();
                let r = (dist * dist + softening * softening).sqrt();
                
                let acc = gravity / (r * r * r) * d;
                
                self.accelerations[i as usize] += acc * m2;
                self.accelerations[j as usize] -= acc * m1;
                self.potential_energy -= gravity * m1 * m2 / r;
            }
        }
    }
    
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