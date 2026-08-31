use godot::prelude::*;

const BORDER_TYPE_NONE: i32 = 0;
const BORDER_TYPE_STOP: i32 = 1;
const BORDER_TYPE_BOUNCE: i32 = 2;
const BORDER_TYPE_WRAPAROUND: i32 = 3;

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

        let world_size: Vector2i = config.get("world_size").to::<Vector2i>();
        let border_type: i32 = config.get("border_type").to::<i32>();
        let timestep: f32 = config.get("timestep").to::<f32>();
        let softening: f32 = config.get("softening").to::<f32>();
        let gravity: f32 = config.get("gravity").to::<f32>();
        
        for _step in 0..steps {
            self.half_kick(timestep);
            self.drift(timestep, world_size.to_vector2(), border_type);
            self.accelerate(softening, gravity);
            self.half_kick(timestep);
        }
    }

    fn half_kick(&mut self, timestep: f32) {
        for i in 0..self.positions.len() {
            self.velocities[i] += self.accelerations[i] * timestep * 0.5;
        }
    }

    fn drift(&mut self, timestep: f32, world_size: Vector2, border_type: i32) {
        for i in 0..self.positions.len() {
            self.positions[i] += self.velocities[i] * timestep;
            self.constrain(i, world_size, border_type);
            self.accelerations[i] = Vector2::ZERO;
        }
    }

    fn constrain(&mut self, i: usize, world_size: Vector2, border_type: i32) {
        let w: f32 = world_size.x;
        let h: f32 = world_size.y;
        let x: f32 = self.positions[i].x;
        let y: f32 = self.positions[i].y;
            
        match border_type {
            BORDER_TYPE_WRAPAROUND => {
                self.positions[i].x = (x.rem_euclid(w) + w).rem_euclid(w);
                self.positions[i].y = (y.rem_euclid(h) + h).rem_euclid(h);
            }
            BORDER_TYPE_STOP => {
                let prev_x = x;
                let prev_y = y;
                self.positions[i].x = x.clamp(0.0, world_size.x);
                self.positions[i].y = y.clamp(0.0, world_size.y);
                if self.positions[i].x != prev_x {
                    self.velocities[i].x = 0.0;
                } if self.positions[i].y != prev_y {
                    self.velocities[i].y = 0.0;
                }
            }
            BORDER_TYPE_BOUNCE => {
                if x < 0.0 || x > world_size.x {
                    let offset = (if x < 0.0 { -x } else { world_size.x - x }) * 2.0;
                    self.positions[i].x += offset;
                    self.velocities[i].x *= -1.0;
                }
                if y < 0.0 || y > world_size.y {
                    let offset = (if y < 0.0 { -y } else { world_size.y - y }) * 2.0;
                    self.positions[i].y += offset;
                    self.velocities[i].y *= -1.0;
                }
            }
            _default => {}
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