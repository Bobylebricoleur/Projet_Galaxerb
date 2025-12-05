
import java.util.Arrays;
import java.lang.Math;

public class RenderNaive {

    private Galaxy galaxie; 
    private float[] accelX;
    private float[] accelY;
    private float[] accelZ;
    
    private final float dt = 0.01f; 

    public RenderNaive(Galaxy g) {
        this.galaxie = g; 
        this.accelX = new float[g.size];
        this.accelY = new float[g.size];
        this.accelZ = new float[g.size];
    }

    public void execute() {
        
        // Initialisation à zéro avec la nouvelle nomenclature
        Arrays.fill(accelX, 0.0f);
        Arrays.fill(accelY, 0.0f);
        Arrays.fill(accelZ, 0.0f);

  
        for (int i = 0; i < galaxie.size; i += 1) {
            for (int j = 0; j < galaxie.size; j += 1) {
                if (i != j) {
                    // Nomenclature mise à jour: galaxie.pos_x[i] devient galaxie.posX[i]
                    final float dx = galaxie.posX[j] - galaxie.posX[i];
                    final float dy = galaxie.posY[j] - galaxie.posY[i];
                    final float dz = galaxie.posZ[j] - galaxie.posZ[i];

                    float dij = dx * dx + dy * dy + dz * dz;

                    float d3;
                    if (dij < 1.0f) {
                        d3 = 10.0f * galaxie.mass[j]; 
                    } else {
                        // Utilisation de Math.sqrt et cast en float pour simuler sqrtf
                        final float sqrtd = (float) Math.sqrt(dij); 
                        d3 = 10.0f * galaxie.mass[j] / (sqrtd * sqrtd * sqrtd); 
                    }

                    // Mise à jour des accélérations avec la nouvelle nomenclature
                    accelX[i] += (dx * d3);
                    accelY[i] += (dy * d3);
                    accelZ[i] += (dz * d3);
                }
            }
        }

        for (int i = 0; i < galaxie.size; i += 1) {
            // Mise à jour de la vitesse (galaxie.vel_x[i] devient galaxie.velX[i])
            galaxie.velX[i] += (accelX[i] * 2.0f);
            galaxie.velY[i] += (accelY[i] * 2.0f);
            galaxie.velZ[i] += (accelZ[i] * 2.0f);

            // Mise à jour de la position (galaxie.pos_x[i] devient galaxie.posX[i])
            galaxie.posX[i] += (galaxie.velX[i] * dt);
            galaxie.posY[i] += (galaxie.velY[i] * dt);
            galaxie.posZ[i] += (galaxie.velZ[i] * dt);
        }
    }

    public Galaxy particules() {
        return galaxie; 
    }
}