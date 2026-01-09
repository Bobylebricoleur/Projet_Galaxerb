// src/file_tools.rs
use crate::galaxy::Galaxy;
use std::f32::consts::PI;
use std::fs::File;
use std::io::{self, BufRead, Write};
use std::path::Path;
use rand::{Rng, SeedableRng};
use rand::rngs::StdRng;

// Équivalent de CreateGalaxy
pub fn create_galaxy(n: usize) -> Galaxy {
    let mut g = Galaxy::new(n);

    // En C++, srand(n) est utilisé.
    // En Rust, on utilise un générateur avec une seed fixe pour reproduire le comportement.
    let mut rng = StdRng::seed_from_u64(n as u64);

    for i_body in 0..n {
        let mi: f32;
        let qix: f32;
        let qiy: f32;
        let qiz: f32;
        let vix: f32;
        let viy: f32;
        let viz: f32;

        if i_body == 0 {
            mi = 2.0e24;
            qix = 0.0;
            qiy = 0.0;
            qiz = 0.0;
            vix = 0.0;
            viy = 0.0;
            viz = 0.0;
        } else {
            mi = rng.gen::<f32>() * 5e20;
            
            let horizontal_angle = rng.gen::<f32>() * 2.0 * PI;
            let vertical_angle = rng.gen::<f32>() * 2.0 * PI;
            let dist_to_center = rng.gen::<f32>() * 1.0e8 + 1.0e8;

            qix = vertical_angle.cos() * horizontal_angle.sin() * dist_to_center;
            qiy = vertical_angle.sin() * dist_to_center;
            qiz = vertical_angle.cos() * horizontal_angle.cos() * dist_to_center;

            vix = qiy * 4.0e-6;
            viy = -qix * 4.0e-6;
            viz = 0.0e2;
        }

        g.pos_x[i_body] = qix;
        g.pos_y[i_body] = qiy;
        g.pos_z[i_body] = qiz;
        g.vel_x[i_body] = vix;
        g.vel_y[i_body] = viy;
        g.vel_z[i_body] = viz;
        g.mass[i_body] = mi;
        g.color[i_body] = 200; // int8 cast implicite si < 127, ici attention au cast
    }

    g
}

pub fn load_from_file(filename: &str, step: usize) -> Galaxy {
    let path = Path::new(filename);
    let file = match File::open(&path) {
        Ok(f) => f,
        Err(_) => {
            eprintln!("(EE) Error opening file ({})", filename);
            std::process::exit(1);
        }
    };

    let reader = io::BufReader::new(file);
    let mut lines = Vec::new();

    for (line_number, line_res) in reader.lines().enumerate() {
        if let Ok(line) = line_res {
            if line_number % step == 0 {
                lines.push(line);
            }
        }
    }

    if lines.is_empty() {
        eprintln!("(EE) Error the file is empty, no particule is loaded");
        std::process::exit(1);
    }

    let size = lines.len();
    let mut g = Galaxy::new(size);
    let is_gxy = filename.contains(".gxy");

    for (i, line) in lines.iter().enumerate() {
        let parts: Vec<&str> = line.split_whitespace().collect();
        // Parsing simplifié basé sur l'espace
        if parts.len() < 8 { continue; } // Sécurité basique

        if is_gxy {
             // Format .gxy : pos_x pos_y pos_z vel_x vel_y vel_z mass color
            g.pos_x[i] = parts[0].parse().unwrap_or(0.0);
            g.pos_y[i] = parts[1].parse().unwrap_or(0.0);
            g.pos_z[i] = parts[2].parse().unwrap_or(0.0);
            g.vel_x[i] = parts[3].parse().unwrap_or(0.0);
            g.vel_y[i] = parts[4].parse().unwrap_or(0.0);
            g.vel_z[i] = parts[5].parse().unwrap_or(0.0);
            g.mass[i]  = parts[6].parse().unwrap_or(0.0);
            g.color[i] = parts[7].parse().unwrap_or(0);
        } else {
             // Format .tab : mass pos_x pos_y pos_z vel_x vel_y vel_z color
            g.mass[i]  = parts[0].parse().unwrap_or(0.0);
            g.pos_x[i] = parts[1].parse().unwrap_or(0.0);
            g.pos_y[i] = parts[2].parse().unwrap_or(0.0);
            g.pos_z[i] = parts[3].parse().unwrap_or(0.0);
            g.vel_x[i] = parts[4].parse().unwrap_or(0.0);
            g.vel_y[i] = parts[5].parse().unwrap_or(0.0);
            g.vel_z[i] = parts[6].parse().unwrap_or(0.0);
            g.color[i] = parts[7].parse().unwrap_or(0);
        }
    }
    
    g
}

pub fn save_to_file(g: &Galaxy, filename: &str, fmt: &str) {
    let path = Path::new(filename);
    let mut file = match File::create(&path) {
        Ok(f) => f,
        Err(_) => {
            eprintln!("(EE) Impossible d'ouvrir le fichier en écriture : {}", filename);
            return;
        }
    };

    for i in 0..g.size {
        let line = if fmt == "tab" {
             format!(
                "{:>15.8e} {:>15.8e} {:>15.8e} {:>15.8e} {:>15.8e} {:>15.8e} {:>15.8e} {:>6}\n",
                g.mass[i], g.pos_x[i], g.pos_y[i], g.pos_z[i], g.vel_x[i], g.vel_y[i], g.vel_z[i], g.color[i]
            )
        } else if fmt == "gxy" {
             format!(
                "{:>15.8e} {:>15.8e} {:>15.8e} {:>15.8e} {:>15.8e} {:>15.8e} {:>15.8e} {:>6}\n",
                g.pos_x[i], g.pos_y[i], g.pos_z[i], g.vel_x[i], g.vel_y[i], g.vel_z[i], g.mass[i], g.color[i]
            )
        } else {
            eprintln!("(EE) Format non supporté : {}", fmt);
            return;
        };
        // Rust n'a pas de "showpos" natif simple dans format! comme C++, 
        // on assume ici que le format standard scientifique suffit, 
        // ou on ajouterait manuellement le "+" si strictement nécessaire.
        let _ = file.write_all(line.as_bytes());
    }
    println!("(II) Galaxie sauvegardée dans {} (format {})", filename, fmt);
}