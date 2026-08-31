use godot::prelude::*;

#[derive(GodotClass)]
#[class(init, base=Resource)]
struct FastCPUSimulation {
    positions: Vec<Vector2>,
    velocities: Vec<Vector2>,
    accelerations: Vec<Vector2>,
    masses: Vec<f32>,

    potential_energy: f32,

    base: Base<Resource>
}

#[godot_api]
impl FastCPUSimulation {
    #[func]
    fn setup(&self, _config: Gd<Resource>) {}

    #[func]
    fn step(&mut self, steps: i32, config: Gd<Resource>) {
        self.potential_energy = 0.0;

        let timestep: f32 = config.get("timestep").to::<f32>();
        let softening: f32 = config.get("softening").to::<f32>();
        let gravity: f32 = config.get("gravity").to::<f32>();
        
        for _step in 0..steps {
            self.half_kick(timestep);
            self.drift(timestep);
            self.accelerate(softening, gravity);
            self.half_kick(timestep);
        }
    }

    fn half_kick(&mut self, timestep: f32) {
        for i in 0..self.positions.len() {
            self.velocities[i] += self.accelerations[i] * timestep * 0.5;
        }
    }

    fn drift(&mut self, timestep: f32) {
        for i in 0..self.positions.len() {
            self.positions[i] += self.velocities[i] * timestep;
            //_constrain(i, config)
            self.accelerations[i] = Vector2::ZERO;
        }
    }

    fn accelerate(&mut self, softening: f32, gravity: f32) {
        let particle_count: i32 = self.positions.len() as i32;
        let softening_sq = softening * softening;

        for i in 0..particle_count {
            let p1 = self.positions[i as usize];
            let m1 = self.masses[i as usize];
            for j in (i + 1)..particle_count {
                let m2 = self.masses[j as usize];

                let d = self.positions[j as usize] - p1;
                let dist_sq = d.length_squared();
                let r = (dist_sq + softening_sq).sqrt();
                
                let acc = gravity / (r * r * r) * d;
                
                self.accelerations[i as usize] += acc * m2;
                self.accelerations[j as usize] -= acc * m1;
                self.potential_energy -= gravity * m1 * m2 / r;
            }
        }
    }
    
    #[func]
    fn set_state(&mut self, positions: PackedVector2Array, velocities: PackedVector2Array, masses: PackedFloat32Array) {
        self.positions = positions.to_vec();
        self.velocities = velocities.to_vec();
        self.masses = masses.to_vec();
        
        self.accelerations = Vec::new();
        self.accelerations.resize(positions.len(), Vector2::ZERO);
    }

    #[func]
    fn get_potential_energy(&self) -> f32 {
        self.potential_energy
    }

    #[func]
    fn get_positions(&self) -> PackedVector2Array {
        PackedVector2Array::from(self.positions.clone())
    }

    #[func]
    fn get_velocities(&self) -> PackedVector2Array {
        PackedVector2Array::from(self.velocities.clone())
    }
}