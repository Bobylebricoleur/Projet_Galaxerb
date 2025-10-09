import java.util.Arrays;

public class Galaxy {
    public int size;
    public float[] posX, posY, posZ;
    public float[] posXNew, posYNew, posZNew;
    public float[] velX, velY, velZ;
    public float[] mass;
    public byte[] color;

    private float minMass = Float.MAX_VALUE;
    private float maxMass = -Float.MAX_VALUE;

    public Galaxy(int size) {
        System.out.println("(II) Création d'une galaxie(" + size + ")");
        this.size = size;
        posX = new float[size];
        posY = new float[size];
        posZ = new float[size];
        posXNew = new float[size];
        posYNew = new float[size];
        posZNew = new float[size];
        velX = new float[size];
        velY = new float[size];
        velZ = new float[size];
        mass = new float[size];
        color = new byte[size];
        System.out.println("(II) Fin de création");
    }

    public void update() {
        for (int i = 0; i < size; i++) {
            posX[i] = posXNew[i];
            posY[i] = posYNew[i];
            posZ[i] = posZNew[i];
        }
    }

    public float minMass() {
        if (minMass == Float.MAX_VALUE) {
            for (float m : mass) {
                if (m < minMass) minMass = m;
            }
        }
        return minMass;
    }

    public float maxMass() {
        if (maxMass == -Float.MAX_VALUE) {
            for (float m : mass) {
                if (m > maxMass) maxMass = m;
            }
        }
        return maxMass;
    }
    public int getNombreParticules() {
        return size;
    }

    public float getMasseTotale() {
        float somme = 0f;
        for (int i = 0; i < size; i++) {
            somme += mass[i];
        }
        return somme;
    }

    public float getMasseMoyenne() {
        if (size == 0) return 0f;
        return getMasseTotale() / size;
    }


}
