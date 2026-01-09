// src/render_naive.rs
use crate::galaxy::Galaxy;

pub struct RenderNaive {
    // En Rust, on sépare souvent les buffers temporaires de la structure de données principale
    // pour éviter les problèmes d'emprunt (borrow checker).
    accel_x: Vec<f32>,
    accel_y: Vec<f32>,
    accel_z: Vec<f32>,
    dt: f32,
}

impl RenderNaive {
    pub fn new(g: &Galaxy) -> Self {
        RenderNaive {
            accel_x: vec![0.0; g.size],
            accel_y: vec![0.0; g.size],
            accel_z: vec![0.0; g.size],
            dt: 0.01,
        }
    }

    pub fn execute(&mut self, galaxie: &mut Galaxy) {
        // bzero equivalent
        self.accel_x.fill(0.0);
        self.accel_y.fill(0.0);
        self.accel_z.fill(0.0);

        let size = galaxie.size;

        // Double boucle O(N^2)
        for i in 0..size {
            for j in 0..size {
                if i != j {
                    let dx = galaxie.pos_x[j] - galaxie.pos_x[i];
                    let dy = galaxie.pos_y[j] - galaxie.pos_y[i];
                    let dz = galaxie.pos_z[j] - galaxie.pos_z[i];

                    let dij = dx * dx + dy * dy + dz * dz;
                    let d3;

                    if dij < 1.0 {
                        d3 = 10.0 * galaxie.mass[j];
                    } else {
                        let sqrtd = dij.sqrt();
                        d3 = 10.0 * galaxie.mass[j] / (sqrtd * sqrtd * sqrtd);
                    }

                    self.accel_x[i] += dx * d3;
                    self.accel_y[i] += dy * d3;
                    self.accel_z[i] += dz * d3;
                }
            }
        }

        // Mise à jour vélocité et position
        for i in 0..size {
            galaxie.vel_x[i] += self.accel_x[i] * 2.0;
            galaxie.vel_y[i] += self.accel_y[i] * 2.0;
            galaxie.vel_z[i] += self.accel_z[i] * 2.0;

            galaxie.pos_x[i] += galaxie.vel_x[i] * self.dt;
            galaxie.pos_y[i] += galaxie.vel_y[i] * self.dt;
            galaxie.pos_z[i] += galaxie.vel_z[i] * self.dt;
        }
    }
}