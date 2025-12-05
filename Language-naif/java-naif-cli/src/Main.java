import java.io.*;
import java.nio.file.*;
import java.util.*;

public class Main {
    public static void main(String[] args) {
        int nbIterations = -1;
        double tempsTraitements = -1.0;
        int nbParticules = -1;
        boolean isIteratif = false;
        boolean isTemporel = false;

        // Gestion des arguments
        for (int i = 0; i < args.length; i++) {
            switch (args[i]) {
                case "-i":
                    nbIterations = Integer.parseInt(args[++i]);
                    isIteratif = true;
                    break;
                case "-t":
                    tempsTraitements = Double.parseDouble(args[++i]);
                    isTemporel = true;
                    break;
                case "-n":
                    nbParticules = Integer.parseInt(args[++i]);
                    break;
                default:
                    System.err.println("Usage: java Main -i <nb_iterations> -n <nb_particules> | -t <temps> -n <nb_particules>");
                    return;
            }
        }
        if (nbParticules <= 0 || (!isIteratif && !isTemporel)) {
            System.err.println("Usage: java Main -i <nb_iterations> -n <nb_particules> | -t <temps> -n <nb_particules>");
            return;
        }

        String filename = "../../data/dubinski_colored.tab";
        try {
            System.out.println("(II) Début du chargement de la constellation");
            Galaxy galaxie = FileTools.loadFromFile(filename, nbParticules);
            System.out.println("(II) Fin du chargement de la constellation");

            if (galaxie.size == 0) {
                System.out.println("(EE) Error the galaxy has no particule (g.size == " + galaxie.size + ")");
                return;
            }

            int cpt = 0;
            double temps = 0.0;
            long startRef = System.nanoTime();
            RenderNaive kRef = new RenderNaive(galaxie);
            long endRef = startRef;

            if (isIteratif) {
                for (int i = 0; i < nbIterations; ++i) {
                    long start = System.nanoTime();
                    kRef.execute();
                    long end = System.nanoTime();
                    double execTime = (end - start) / 1e9;
                    System.out.println("ExecTime = " + execTime + " sec.");
                }
                cpt = nbIterations;
                endRef = System.nanoTime();
            } else if (isTemporel) {
                startRef = System.nanoTime();
                cpt = 0;
                temps = 0.0;
                while (temps <= tempsTraitements) {
                    long start = System.nanoTime();
                    cpt++;
                    kRef.execute();
                    long end = System.nanoTime();
                    double execTime = (end - start) / 1e9;
                    temps += execTime;
                    System.out.println("Exécution n° " + cpt + " ExecTime = " + execTime + " sec.");
                }
                endRef = System.nanoTime();
            }

            // Calcul des caractéristiques
            double total_mass = 0.0;
            double sum_pos_x = 0.0, sum_pos_y = 0.0, sum_pos_z = 0.0;
            double sum_vel_x = 0.0, sum_vel_y = 0.0, sum_vel_z = 0.0;

            for (int i = 0; i < galaxie.size; i++) {
                total_mass += galaxie.mass[i];
                sum_pos_x += galaxie.mass[i] * galaxie.posX[i];
                sum_pos_y += galaxie.mass[i] * galaxie.posY[i];
                sum_pos_z += galaxie.mass[i] * galaxie.posZ[i];

                sum_vel_x += galaxie.velX[i];
                sum_vel_y += galaxie.velY[i];
                sum_vel_z += galaxie.velZ[i];
            }

            double mean_mass = total_mass / galaxie.size;
            double center_x = sum_pos_x / total_mass;
            double center_y = sum_pos_y / total_mass;
            double center_z = sum_pos_z / total_mass;

            double mean_vel_x = sum_vel_x / galaxie.size;
            double mean_vel_y = sum_vel_y / galaxie.size;
            double mean_vel_z = sum_vel_z / galaxie.size;
            double tmps_tot = (endRef - startRef) / 1e9;
            double tmps_mean = tmps_tot / cpt;

            System.out.println("=========================== caractéristique de la galaxie  =========================== ");
            System.out.println("Nombre de particules : " + galaxie.size);
            System.out.printf(Locale.US, "Masse totale         : %.3e\n", total_mass);
            System.out.printf(Locale.US, "Masse moyenne        : %.3e\n", mean_mass);
            System.out.printf(Locale.US, "Centre de masse      : (%.3e, %.3e, %.3e)\n", center_x, center_y, center_z);
            System.out.printf(Locale.US, "Vitesse moyenne      : (%.3e, %.3e, %.3e)\n", mean_vel_x, mean_vel_y, mean_vel_z);
            System.out.println("=========================== ============================== =========================== ");
            System.out.println("=========================== Calculs temporels  =========================== ");
            System.out.printf(Locale.US, "Temps moyen par itération : %.4f sec.\n", tmps_mean);
            System.out.printf(Locale.US, "Temps total pour %d itérations : %.4f sec.\n", cpt, tmps_tot);
            System.out.println("=========================== ============================== =========================== ");

            Galaxy gr = kRef.particules();
            FileTools.saveToFile(gr, "particules.out", "tab");

            // Écriture CSV
            String csvPath = "resultats/java_results.csv";
            new FileWriter("resultats/java_results.csv", false).close();
            boolean writeHeader = !Files.exists(Paths.get(csvPath)) || Files.size(Paths.get(csvPath)) == 0;
            
            try (FileWriter fw = new FileWriter(csvPath, true)) {
                if (writeHeader) {
                    fw.write("lang,mode,nb_particules,total_mass,mean_mass,center_x,center_y,center_z,mean_vel_x,mean_vel_y,mean_vel_z,tmps_mean,tmps_total,caracteristiques,calculs_temporels\n");
                }
                String carac = String.format(Locale.US,
                        "Nombre de particules : %d; Masse totale : %.3e; Masse moyenne : %.3e; Centre de masse : (%.3e, %.3e, %.3e); Vitesse moyenne : (%.3e, %.3e, %.3e)",
                        galaxie.size, total_mass, mean_mass, center_x, center_y, center_z, mean_vel_x, mean_vel_y, mean_vel_z);
                String temp = String.format(Locale.US,
                        "Temps moyen par itération : %.4f sec.; Temps total : %.4f sec.", tmps_mean, tmps_tot);
                fw.write(String.format(Locale.US,
                        "java,%s,%d,%.3e,%.3e,%.3e,%.3e,%.3e,%.3e,%.3e,%.3e,%.4f,%.4f,\"%s\",\"%s\"\n",
                        isIteratif ? "iteration" : "temporel", nbParticules, total_mass, mean_mass,
                        center_x, center_y, center_z, mean_vel_x, mean_vel_y, mean_vel_z, tmps_mean, tmps_tot, carac, temp));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}


