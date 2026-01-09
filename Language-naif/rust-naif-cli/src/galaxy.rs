// src/galaxy.rs
use std::f32;

#[derive(Clone)]
pub struct Galaxy {
    pub size: usize,
    pub pos_x: Vec<f32>,
    pub pos_y: Vec<f32>,
    pub pos_z: Vec<f32>,
    pub pos_x_new: Vec<f32>,
    pub pos_y_new: Vec<f32>,
    pub pos_z_new: Vec<f32>,
    pub mass: Vec<f32>,
    pub vel_x: Vec<f32>,
    pub vel_y: Vec<f32>,
    pub vel_z: Vec<f32>,
    pub color: Vec<u8>,
}

impl Galaxy {
    pub fn new(size: usize) -> Self {
        println!("(II) Création d'une galaxie({})", size);
        let g = Galaxy {
            size,
            pos_x: vec![0.0; size],
            pos_y: vec![0.0; size],
            pos_z: vec![0.0; size],
            pos_x_new: vec![0.0; size],
            pos_y_new: vec![0.0; size],
            pos_z_new: vec![0.0; size],
            mass: vec![0.0; size],
            vel_x: vec![0.0; size],
            vel_y: vec![0.0; size],
            vel_z: vec![0.0; size],
            color: vec![0; size],
        };
        println!("(II) Fin de création");
        return g
        
    }

    pub fn update(&mut self) {
        for i in 0..self.size {
            self.pos_x[i] = self.pos_x_new[i];
            self.pos_y[i] = self.pos_y_new[i];
            self.pos_z[i] = self.pos_z_new[i];
        }
    }
}