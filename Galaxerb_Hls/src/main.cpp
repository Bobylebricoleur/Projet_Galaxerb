#include "RenderNaive.hpp"
#include "FileTools.hpp"
#include <fstream>
#include <getopt.h>
#include <vector>
#include <cstring> // pour memcpy

// --- Gestionnaire de Mémoire pour l'Embarqué ---
struct SimulationHistory {
    // On stocke tout à plat pour faciliter le transfert DMA futur
    // Layout: [Iteration 0 Data][Iteration 1 Data]...
    // Au sein d'une itération, on garde le format SoA pour être cohérent avec le calcul
    // Data: pos_x[], pos_y[], pos_z[], vel_x[], vel_y[], vel_z[], mass[]
    
    float* buffer;
    size_t total_size_bytes;
    int n_particles;
    int n_iterations;
    int current_iter;

    SimulationHistory(int n, int iters) : n_particles(n), n_iterations(iters), current_iter(0) {
        // 7 float par particule (x, y, z, vx, vy, vz, mass)
        size_t elements_per_iter = n_particles * 7;
        size_t total_elements = elements_per_iter * n_iterations;
        total_size_bytes = total_elements * sizeof(float);

        std::cout << "(II) Allocation Memoire Historique: " 
                  << (total_size_bytes / 1024.0 / 1024.0) << " MB" << std::endl;

        // Allocation unique et contiguë (Essentiel pour Vitis/DMA)
        buffer = new float[total_elements];
        
        if (!buffer) {
            std::cerr << "(EE) Echec allocation memoire ! Trop gros pour la Zybo ?" << std::endl;
            exit(1);
        }

        std::cerr << "CHIASSE COULANTE" << std::endl;

    }

    ~SimulationHistory() {
        if (buffer) delete[] buffer;
    }

    // Sauvegarde l'état actuel de la galaxie dans le buffer
    void capture_state(Galaxy* g) {
        if (current_iter >= n_iterations) return;

        size_t offset = (size_t)current_iter * (n_particles * 7);
        float* ptr = buffer + offset;
        
        // Copie rapide par bloc (memcpy est très optimisé sur ARM NEON)
        // On copie les vecteurs SoA un par un à la suite
        size_t block_size = n_particles * sizeof(float);

        std::memcpy(ptr, g->pos_x, block_size); ptr += n_particles;
        std::memcpy(ptr, g->pos_y, block_size); ptr += n_particles;
        std::memcpy(ptr, g->pos_z, block_size); ptr += n_particles;
        std::memcpy(ptr, g->vel_x, block_size); ptr += n_particles;
        std::memcpy(ptr, g->vel_y, block_size); ptr += n_particles;
        std::memcpy(ptr, g->vel_z, block_size); ptr += n_particles;
        std::memcpy(ptr, g->mass,  block_size); 

        current_iter++;
    }

    // Fonction pour dumper le buffer sur disque APRES le calcul (pour validation)
    void dump_to_file(const std::string& filename) {
        std::cout << "(II) Ecriture des resultats sur disque..." << std::endl;
        std::ofstream file(filename, std::ios::binary); // Binaire pour la vitesse
        if (file.is_open()) {
            file.write(reinterpret_cast<const char*>(buffer), total_size_bytes);
            file.close();
        }
    }
};

int main(int argc, char ** argv)
{
    int nb_iterations = 10; // Valeur par defaut
    int nbParticules  = 32; // Valeur par defaut adaptée

    std::cout << "Simulation: " << nbParticules << " particules, " 
              << nb_iterations << " iterations." << std::endl;

    // 1. Initialisation Galaxie
    Galaxy* galaxie = CreateGalaxy(nbParticules);
    
    // 2. Initialisation Renderer
    RenderNaive render(*galaxie);

    // 3. Initialisation Buffer Mémoire (Nouveau pour Zybo)
    SimulationHistory history(nbParticules, nb_iterations);

    // Initialisation fichiers de sortie (optionnel si on dump tout à la fin)
    // ...

    std::cout << "Debut du calcul..." << std::endl;
    auto start = std::chrono::high_resolution_clock::now();

    // === Boucle Principale ===
    for (int i = 0; i < nb_iterations; i++)
    {
        // A. Sauvegarde état courant dans la RAM (rapide)
        history.capture_state(galaxie);

        // B. Calcul Physique (Lourd - ce sera la partie FPGA plus tard)
        render.execute();

        if (i % 10 == 0) std::cout << "\rIter: " << i << std::flush;
    }

    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> diff = end - start;
    std::cout << "\nTermine en " << diff.count() << " s" << std::endl;

    // 4. Post-traitement : Sauvegarde ou Vérification
    // Sur la Zybo, on écrira ça sur la carte SD une fois le temps critique passé
    history.dump_to_file("simulation_output.bin");

    return 0;
}