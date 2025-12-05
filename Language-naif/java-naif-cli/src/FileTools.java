import java.io.*;
import java.util.*;

public class FileTools {

    public static Galaxy loadFromFile(String filename, int step) throws IOException {
        if (filename.endsWith(".gxy")) {
            return loadGxyFromFile(filename, step);
        } else if (filename.endsWith(".tab")) {
            return loadTabFromFile(filename, step);
        } else {
            throw new IOException("(EE) Format de fichier non supporté: " + filename);
        }
    }

    private static Galaxy loadTabFromFile(String filename, int step) throws IOException {
        List<String> lines = filterLines(filename, step);
        if (lines.isEmpty()) {
            throw new IOException("(EE) Fichier vide, aucune particule chargée.");
        }
        Galaxy g = new Galaxy(lines.size());
        for (int i = 0; i < lines.size(); i++) {
            String[] tokens = lines.get(i).trim().split("\\s+");
            g.mass[i] = Float.parseFloat(tokens[0]);
            g.posX[i] = Float.parseFloat(tokens[1]);
            g.posY[i] = Float.parseFloat(tokens[2]);
            g.posZ[i] = Float.parseFloat(tokens[3]);
            g.velX[i] = Float.parseFloat(tokens[4]);
            g.velY[i] = Float.parseFloat(tokens[5]);
            g.velZ[i] = Float.parseFloat(tokens[6]);
            g.color[i] = (byte) Integer.parseInt(tokens[7]);
        }
        return g;
    }

    private static Galaxy loadGxyFromFile(String filename, int step) throws IOException {
        List<String> lines = filterLines(filename, step);
        if (lines.isEmpty()) {
            throw new IOException("(EE) Fichier vide, aucune particule chargée.");
        }
        Galaxy g = new Galaxy(lines.size());
        for (int i = 0; i < lines.size(); i++) {
            String[] tokens = lines.get(i).trim().split("\\s+");
            g.posX[i] = Float.parseFloat(tokens[0]);
            g.posY[i] = Float.parseFloat(tokens[1]);
            g.posZ[i] = Float.parseFloat(tokens[2]);
            g.velX[i] = Float.parseFloat(tokens[3]);
            g.velY[i] = Float.parseFloat(tokens[4]);
            g.velZ[i] = Float.parseFloat(tokens[5]);
            g.mass[i] = Float.parseFloat(tokens[6]);
            g.color[i] = (byte) Integer.parseInt(tokens[7]);
        }
        return g;
    }

    private static List<String> filterLines(String filename, int step) throws IOException {
        List<String> list = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            int lineNumber = 0;
            while ((line = br.readLine()) != null) {
                if (lineNumber % step == 0) {
                    list.add(line);
                }
                lineNumber++;
            }
        }
        return list;
    }

    public static void saveToFile(Galaxy g, String filename, String fmt) {
        
        final String DOUBLE_FORMAT = "%+15.8e";
        final String COLOR_FORMAT = "%6d"; // Pas de signe pour la couleur.
        final String SEPARATOR = " ";
        final String BIGSEPARATOR = "      ";
        final String NEWLINE = "\n";

        PrintWriter writer = null;
        try {
            // Ouvrir le fichier en écriture
            writer = new PrintWriter(new FileWriter(new File(filename)));

            for (int i = 0; i < g.size; i++) {
                if ("tab".equals(fmt)) {
                    writer.printf(DOUBLE_FORMAT, g.mass[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.posX[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.posY[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.posZ[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.velX[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.velY[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.velZ[i]);
                    writer.print(SEPARATOR);
                    writer.printf(COLOR_FORMAT, g.color[i] & 0xFF); 
                    writer.print(NEWLINE); 

                } else if ("gxy".equals(fmt)) {
                    
                    
                    writer.printf(DOUBLE_FORMAT, g.posX[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.posY[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.posZ[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.velX[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.velY[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.velZ[i]);
                    writer.print(SEPARATOR);
                    writer.printf(DOUBLE_FORMAT, g.mass[i]);
                    writer.print(SEPARATOR);
                    writer.printf(COLOR_FORMAT, g.color[i] & 0xFF);
                    writer.print(NEWLINE); 
                    
                } else {
                    // Format non supporté
                    System.err.println("(EE) Format non supporté : " + fmt);
                    return; // Le return sort de la fonction et ne ferme pas le writer ici.
                }
            }
            
            // Si tout s'est bien passé
            System.out.println("(II) Galaxie sauvegardée dans " + filename + " (format " + fmt + ")");

        } catch (IOException e) {
            // Gestion de l'erreur d'ouverture de fichier ou d'écriture
            System.err.println("(EE) Impossible d'ouvrir le fichier en écriture : " + filename);
            // e.printStackTrace(); // Utile pour le débogage, mais laissé de côté pour coller au style C++
        } finally {
            // Fermeture du PrintWriter
            if (writer != null) {
                writer.close();
            }
        }
    }
}
