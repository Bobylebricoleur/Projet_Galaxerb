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

    public static void saveToFile(Galaxy g, String filename, String fmt) throws IOException {
        try (PrintWriter pw = new PrintWriter(new FileWriter(filename))) {
            for (int i = 0; i < g.size; i++) {
                if (fmt.equals("tab")) {
                    pw.printf("% .8e % .8e % .8e % .8e % .8e % .8e % .8e %d%n",
                            g.mass[i], g.posX[i], g.posY[i], g.posZ[i],
                            g.velX[i], g.velY[i], g.velZ[i], g.color[i]);
                } else if (fmt.equals("gxy")) {
                    pw.printf("% .8e % .8e % .8e % .8e % .8e % .8e % .8e %d%n",
                            g.posX[i], g.posY[i], g.posZ[i],
                            g.velX[i], g.velY[i], g.velZ[i],
                            g.mass[i], g.color[i]);
                } else {
                    throw new IOException("(EE) Format non supporté: " + fmt);
                }
            }
        }
        System.out.println("(II) Galaxie sauvegardée dans " + filename + " (format " + fmt + ")");
    }
}
