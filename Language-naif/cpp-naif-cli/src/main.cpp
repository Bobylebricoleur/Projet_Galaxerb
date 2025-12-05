/*
 *  Copyright (c) 2022 Bertrand LE GAL
 *
 *  This software is provided 'as-is', without any express or
 *  implied warranty. In no event will the authors be held
 *  liable for any damages arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute
 *  it freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented;
 *  you must not claim that you wrote the original software.
 *  If you use this software in a product, an acknowledgment
 *  in the product documentation would be appreciated but
 *  is not required.
 *
 *  2. Altered source versions must be plainly marked as such,
 *  and must not be misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any
 *  source distribution.
 *
 */
#include "RenderNaive.hpp"
#include "FileTools.hpp"
#include <fstream>
#include <getopt.h>

int main( int argc, char ** argv )
{

    // === Gestion des arguments ===
    int nb_iterations = -1;
    double temps_traitements = -1.0;
    int nbParticules = -1;
    bool is_iteratif = false;
    bool is_temporel = false;

    int opt;
    while ((opt = getopt(argc, argv, "i:t:n:")) != -1) {
        switch (opt) {
            case 'i':
                nb_iterations = std::stoi(optarg);
                is_iteratif = true;
                break;
            case 't':
                temps_traitements = std::stod(optarg);
                is_temporel = true;
                break;
            case 'n':
                nbParticules = std::stoi(optarg);
                break;
            default:
                std::cerr << "Usage: " << argv[0] << " -i <nb_iterations> -n <nb_particules> | -t <temps> -n <nb_particules>" << std::endl;
                return 1;
        }
    }
    if (nbParticules <= 0 || (!is_iteratif && !is_temporel)) {
        std::cerr << "Usage: " << argv[0] << " -i <nb_iterations> -n <nb_particules> | -t <temps> -n <nb_particules>" << std::endl;
        return 1;
    }

    std::string filename = "../../data/dubinski_colored.tab";

    std::cout << "(II) Début du chargement de la constellation" << std::endl;
    Galaxy* galaxie = load_from_file( filename, nbParticules );
    std::cout << "(II) Fin du chargement de la constellation" << std::endl;

    int cpt = 0;
    double temps = 0.0;
    auto start_ref = std::chrono::steady_clock::now();
    RenderNaive* k_ref = new RenderNaive( *galaxie );

    auto end_ref = start_ref;
    if (is_iteratif) {
        for (int i = 0; i < nb_iterations; ++i) {
            auto start = std::chrono::steady_clock::now();
            k_ref->execute();
            auto end = std::chrono::steady_clock::now();
            double execTime = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count() / 1000.f;
            std::cout << "ExecTime = " << execTime << " sec." << std::endl;
        }
        cpt = nb_iterations;
        end_ref = std::chrono::steady_clock::now();
    } else if (is_temporel) {
        //start_ref = std::chrono::steady_clock::now();
        cpt = 0;
        temps = 0.0;
        while (temps <= temps_traitements) {
            auto start = std::chrono::steady_clock::now();
            cpt++;
            k_ref->execute();
            auto end = std::chrono::steady_clock::now();
            double execTime = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count() / 1000.f;
            temps += execTime;
            std::cout << "Exécution n° " << cpt << " ExecTime = " << execTime << " sec." << std::endl;
        }
        end_ref = std::chrono::steady_clock::now();
    }

    if( galaxie->size == 0 )
    {
        std::cout << "(EE) Error the galaxy has no paricule (g.size == " << galaxie->size << ")" << std::endl;
        exit( EXIT_FAILURE );
    }
    
   
 
   
    //
	////////////////////////////////////////////////////////////////////////////////////
	//
    // === Calcul des caractéristiques ===
    double total_mass = 0.0;
    double sum_pos_x = 0.0, sum_pos_y = 0.0, sum_pos_z = 0.0;
    double sum_vel_x = 0.0, sum_vel_y = 0.0, sum_vel_z = 0.0;

    for (int i = 0; i < galaxie->size; i++) {
        total_mass += galaxie->mass[i];
        sum_pos_x += galaxie->mass[i] * galaxie->pos_x[i];
        sum_pos_y += galaxie->mass[i] * galaxie->pos_y[i];
        sum_pos_z += galaxie->mass[i] * galaxie->pos_z[i];

        sum_vel_x += galaxie->vel_x[i];
        sum_vel_y += galaxie->vel_y[i];
        sum_vel_z += galaxie->vel_z[i];
    }

    double mean_mass = total_mass / galaxie->size;
    double center_x = sum_pos_x / total_mass;
    double center_y = sum_pos_y / total_mass;
    double center_z = sum_pos_z / total_mass;

    double mean_vel_x = sum_vel_x / galaxie->size;
    double mean_vel_y = sum_vel_y / galaxie->size;
    double mean_vel_z = sum_vel_z / galaxie->size;
    std::chrono::duration<double> duration_tot = end_ref - start_ref;
    double tmps_tot = duration_tot.count();          // durée totale en secondes
    double tmps_mean = tmps_tot / nb_iterations;       
    //
	////////////////////////////////////////////////////////////////////////////////////
	//
    std::cout << "=========================== caractéristique de la galaxie  =========================== "<< std::endl;
    std::cout << "Nombre de particules : " << galaxie -> size << std::endl;
    std::cout << std::scientific << std::setprecision(3);
    std::cout << "Masse totale         : " << total_mass << std::endl;
    std::cout << "Masse moyenne        : " << mean_mass << std::endl;
    std::cout << "Centre de masse      : (" << center_x << ", " << center_y << ", " << center_z << ")" << std::endl;
    std::cout << "Vitesse moyenne      : ("<< mean_vel_x << ", " << mean_vel_y << ", " << mean_vel_z << ")" << std::endl;
    std::cout << "=========================== ============================== =========================== "<< std::endl;
    std::cout << "=========================== Calculs temporels  =========================== "<< std::endl;
    std::cout << "Temps moyen par itération : " << tmps_mean << " sec." << std::endl;
    std::cout << "Temps total pour " << nb_iterations << " itérations : " << tmps_tot << " sec." << std::endl;
    std::cout << "=========================== ============================== =========================== " <<std::endl;

    //
	////////////////////////////////////////////////////////////////////////////////////
	//

    Galaxy* gr = k_ref->particules();
    save_to_file( gr, "particules.out", "tab" );

  /*   std::ofstream out("results/cpp_results.csv", std::ios::app);
    if (out.tellp() == 0) {
        out << "lang,nb_particules,total_mass,mean_mass,center_x,center_y,center_z,mean_vel_x,mean_vel_y,mean_vel_z,tmps_mean,tmps_total,caracteristiques,calculs_temporels\n";
    }
    // Caractéristiques de la galaxie
    std::ostringstream carac;
    carac << "Nombre de particules : " << galaxie->size << "; ";
    carac << "Masse totale : " << total_mass << "; ";
    carac << "Masse moyenne : " << mean_mass << "; ";
    carac << "Centre de masse : (" << center_x << ", " << center_y << ", " << center_z << "); ";
    carac << "Vitesse moyenne : (" << mean_vel_x << ", " << mean_vel_y << ", " << mean_vel_z << ")";

    // Calculs temporels
    std::ostringstream temp;
    temp << "Temps moyen par itération : " << tmps_mean << " sec.; ";
    temp << "Temps total : " << tmps_tot << " sec.";

    out << "cpp,";
    if (is_iteratif) out << "iteration";
    else if (is_temporel) out << "temporel";
    out << "," << nbParticules << ","
        << total_mass << "," << mean_mass << ","
        << center_x << "," << center_y << "," << center_z << ","
        << mean_vel_x << "," << mean_vel_y << "," << mean_vel_z << ","
        << tmps_mean << "," << tmps_tot << ","
        << '"' << carac.str() << '"' << ","
        << '"' << temp.str() << '"' << "\n";
    out.close(); */


 
	//
	////////////////////////////////////////////////////////////////////////////////////
	//

    return 0;
}

