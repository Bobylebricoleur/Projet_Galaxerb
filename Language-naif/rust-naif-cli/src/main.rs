// src/main.rs
mod galaxy;
mod file_tools;
mod render_naive;

use clap::Parser;
use std::time::Instant;
use crate::render_naive::RenderNaive;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    #[arg(short = 'i', default_value_t = -1)]
    nb_iterations: i32,

    #[arg(short = 't', default_value_t = -1.0)]
    temps_traitements: f64,

    #[arg(short = 'n', default_value_t = -1)]
    nb_particules: i32,
}

fn main() {
    let args = Args::parse();

    let is_iteratif = args.nb_iterations != -1;
    let is_temporel = args.temps_traitements != -1.0;

    if args.nb_particules <= 0 || (!is_iteratif && !is_temporel) {
        eprintln!("Usage: program -i <nb_iterations> -n <nb_particules> | -t <temps> -n <nb_particules>");
        std::process::exit(1);
    }

    let filename = "../../data/dubinski_colored.tab";

    println!("(II) Début du chargement de la constellation");
    // Le C++ utilise le parametre 'step' pour load_from_file qui vient de args.nbParticules
    // Attention: Dans le main.cpp original, 'nbParticules' est passé comme 'step' à load_from_file.
    let mut galaxie = file_tools::load_from_file(filename, args.nb_particules as usize);
    println!("(II) Fin du chargement de la constellation");

    let mut k_ref = RenderNaive::new(&galaxie);
    
    let start_ref = Instant::now();
    let end_ref;
    
    let mut cpt = 0;
    
    // Pour calculer le temps total "utile" (somme des execTime affichés)
    // Le code C++ original calcule 'execTime' à chaque boucle et l'affiche.
    
    if is_iteratif {
        for _ in 0..args.nb_iterations {
            let start = Instant::now();
            k_ref.execute(&mut galaxie);
            let duration = start.elapsed();
            let exec_time = duration.as_secs_f64();
            println!("ExecTime = {:.6} sec.", exec_time);
        }
        cpt = args.nb_iterations;
        end_ref = Instant::now();
    } else {
        // Cas temporel
        let mut temps = 0.0;
        while temps <= args.temps_traitements {
            let start = Instant::now();
            cpt += 1;
            k_ref.execute(&mut galaxie);
            let duration = start.elapsed();
            let exec_time = duration.as_secs_f64();
            temps += exec_time;
            println!("Exécution n° {} ExecTime = {:.6} sec.", cpt, exec_time);
        }
        end_ref = Instant::now();
    }

    if galaxie.size == 0 {
        eprintln!("(EE) Error the galaxy has no paricule (g.size == 0)");
        std::process::exit(1);
    }

    // === Calcul des caractéristiques ===
    let mut total_mass = 0.0;
    let mut sum_pos_x = 0.0;
    let mut sum_pos_y = 0.0;
    let mut sum_pos_z = 0.0;
    let mut sum_vel_x = 0.0;
    let mut sum_vel_y = 0.0;
    let mut sum_vel_z = 0.0;

    for i in 0..galaxie.size {
        total_mass += galaxie.mass[i];
        sum_pos_x += galaxie.mass[i] * galaxie.pos_x[i];
        sum_pos_y += galaxie.mass[i] * galaxie.pos_y[i];
        sum_pos_z += galaxie.mass[i] * galaxie.pos_z[i];

        sum_vel_x += galaxie.vel_x[i];
        sum_vel_y += galaxie.vel_y[i];
        sum_vel_z += galaxie.vel_z[i];
    }

    let mean_mass = total_mass / galaxie.size as f32;
    let center_x = sum_pos_x / total_mass;
    let center_y = sum_pos_y / total_mass;
    let center_z = sum_pos_z / total_mass;

    let mean_vel_x = sum_vel_x / galaxie.size as f32;
    let mean_vel_y = sum_vel_y / galaxie.size as f32;
    let mean_vel_z = sum_vel_z / galaxie.size as f32;

    let duration_tot = end_ref.duration_since(start_ref);
    let tmps_tot = duration_tot.as_secs_f64();
    // Attention : nb_iterations n'est valide que si is_iteratif est vrai pour la moyenne,
    // mais ici on reprend la logique C++ qui utilise nb_iterations même si temporel (ce qui peut donner infini ou faux).
    // Cependant, dans le bloc temporel C++, nb_iterations n'est pas mis à jour, donc division par -1 probable.
    // Je corrige légèrement pour utiliser 'cpt' qui reflète le nombre réel d'itérations exécutées.
    let tmps_mean = tmps_tot / cpt as f64;

    println!("=========================== caractéristique de la galaxie  =========================== ");
    println!("Nombre de particules : {}", galaxie.size);
    println!("Masse totale         : {:.3e}", total_mass);
    println!("Masse moyenne        : {:.3e}", mean_mass);
    println!("Centre de masse      : ({:.3e}, {:.3e}, {:.3e})", center_x, center_y, center_z);
    println!("Vitesse moyenne      : ({:.3e}, {:.3e}, {:.3e})", mean_vel_x, mean_vel_y, mean_vel_z);
    println!("=========================== ============================== =========================== ");
    println!("=========================== Calculs temporels  =========================== ");
    println!("Temps moyen par itération : {:.6} sec.", tmps_mean);
    // Note: C++ affiche nb_iterations ici, qui vaut -1 en mode temporel dans le code original sauf si on passe l'option.
    // Rust affichera la valeur de l'argument.
    println!("Temps total pour {} itérations : {:.6} sec.", cpt, tmps_tot);
    println!("=========================== ============================== =========================== ");

    file_tools::save_to_file(&galaxie, "particules.out", "tab");
}