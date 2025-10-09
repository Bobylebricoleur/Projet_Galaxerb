
import time
import numpy as np
import csv, os
import sys
import getopt
from FileTools import load_from_file, save_to_file
from RenderNaive import RenderNaive

def main():

    # Utilisation de getopt pour choisir le mode
    try:
        opts, args = getopt.getopt(sys.argv[1:], "i:t:n:", ["iteration=", "temporel=", "nbparticules="])
    except getopt.GetoptError as err:
        print(err)
        print(f"Usage: python {sys.argv[0]} -i <nb_iterations> -n <nb_particules> | -t <temps> -n <nb_particules>")
        sys.exit(2)

    nbParticulesParCycle = None
    nb_iterations = None
    temps_traitements = None
    is_iteratif = False
    is_temporel = False
    for opt, arg in opts:
        if opt in ("-i", "--iteration"):
            nb_iterations = int(arg)
            is_iteratif = True
        elif opt in ("-t", "--temporel"):
            temps_traitements = float(arg)
            is_temporel = True
        elif opt in ("-n", "--nbParticulesParCycle"):
            nbParticulesParCycle = int(arg)

    if nbParticulesParCycle is None or (not is_iteratif and not is_temporel):
        print(f"Usage: python {sys.argv[0]} -i <nb_iterations> -n <nb_particules> | -t <temps> -n <nb_particules>")
        sys.exit(2)

    filename = "../data/dubinski_colored.tab"
    print("(II) Début du chargement de la constellation")
    galaxie = load_from_file(filename, nbParticulesParCycle)
    print("(II) Fin du chargement de la constellation")

    if galaxie.size == 0:
        print(f"(EE) Erreur : la galaxie est vide (g.size == {galaxie.size})")
        exit(1)

    k_ref = RenderNaive(galaxie)

    start_ref1 = time.perf_counter()

    # Mode itératif
    if is_iteratif:
        for i in range(nb_iterations):
            start = time.perf_counter()
            k_ref.execute()
            end = time.perf_counter()
            exec_time = end - start
            print(f"ExecTime = {exec_time:.4f} sec.")
        end_ref1 = time.perf_counter()
        start_ref2 = end_ref1
        cpt = nb_iterations

    # Mode temporel
    elif is_temporel:
        end_ref1 = time.perf_counter()
        start_ref2 = time.perf_counter()
        cpt = 0
        temps = 0.0
        while temps <= temps_traitements:
            start = time.perf_counter()
            cpt += 1
            k_ref.execute()
            end = time.perf_counter()
            exec_time = end - start
            temps += exec_time
            print(f"Exécution n° {cpt} - ExecTime = {exec_time:.4f} sec.")
        end_ref2 = time.perf_counter()
    # === Caractéristiques ===
    total_mass = np.sum(galaxie.mass)
    mean_mass = total_mass / galaxie.size

    center_of_mass = np.array([
        np.sum(galaxie.mass * galaxie.pos_x) / total_mass,
        np.sum(galaxie.mass * galaxie.pos_y) / total_mass,
        np.sum(galaxie.mass * galaxie.pos_z) / total_mass,
    ])

    mean_velocity = np.array([
        np.mean(galaxie.vel_x),
        np.mean(galaxie.vel_y),
        np.mean(galaxie.vel_z),
    ])

    if is_iteratif:
        duration_tot = end_ref1 - start_ref1
        tmps_mean = duration_tot / nb_iterations
    else:
        duration_tot = end_ref2 - start_ref2
        tmps_mean = duration_tot / cpt

    print("="*90)
    print("=== Caractéristiques de la galaxie ===")
    print(f"Nombre de particules : {galaxie.size}")
    print(f"Masse totale         : {total_mass:.3e}")
    print(f"Masse moyenne        : {mean_mass:.3e}")
    print(f"Centre de masse      : {center_of_mass}")
    print(f"Vitesse moyenne      : {mean_velocity}")
    print("="*90)

    print("=== Calculs temporels ===")
    print(f"Temps moyen par itération : {tmps_mean:.4f} sec.")
    print(f"Temps total               : {duration_tot:.4f} sec.")
    print("="*90)

    # === Sauvegarde ===
    gr = k_ref.particules()
    save_to_file(gr, "python-naif-cli\src\results\particules.out", "tab")
    print("(II) Galaxie sauvegardée dans 'particules.out'")

    # === Sauvegarde dans le fichier csv ===
    file_csv = "python-naif-cli\resultats\python_results.csv"
    

    header = [
        "lang","nb_particules","total_mass","mean_mass",
        "center_x","center_y","center_z",
        "mean_vel_x","mean_vel_y","mean_vel_z",
        "tmps_mean","tmps_total",
        "caracteristiques","calculs_temporels"
    ]

    write_header = not os.path.exists(file_csv)

    # Caractéristiques de la galaxie
    carac = f"Nombre de particules : {galaxie.size}; Masse totale : {total_mass:.3e}; Masse moyenne : {mean_mass:.3e}; " \
            f"Centre de masse : ({center_of_mass[0]:.3e}, {center_of_mass[1]:.3e}, {center_of_mass[2]:.3e}); " \
            f"Vitesse moyenne : ({mean_velocity[0]:.3e}, {mean_velocity[1]:.3e}, {mean_velocity[2]:.3e})"
    
    # Calculs temporels
    temp = f"Temps moyen par itération : {tmps_mean:.4f} sec.; Temps total : {duration_tot:.4f} sec."

    with open(file_csv, "a", newline="") as f:
        open(file_csv, "w").close()
        writer = csv.writer(f)
        writer.writerow(header)  # Écrit l’en-tête, puis tu ajoutes tes lignes normalement
        writer.writerow([
            "python",
            "iteration" if is_iteratif else "temporel",
            galaxie.size,
            total_mass, mean_mass,
            center_of_mass[0], center_of_mass[1], center_of_mass[2],
            mean_velocity[0], mean_velocity[1], mean_velocity[2],
            tmps_mean, duration_tot,
            carac, temp
        ])

if __name__ == "__main__":
    main()
