public class RenderNaive {
    private Galaxy galaxie;
    private float[] accelX, accelY, accelZ;
    private final float dt = 0.01f;

    public RenderNaive(Galaxy g) {
        this.galaxie = g;
        accelX = new float[g.size];
        accelY = new float[g.size];
        accelZ = new float[g.size];
    }

    public void execute() {
        for (int i = 0; i < galaxie.size; i++) {
            accelX[i] = accelY[i] = accelZ[i] = 0f;
        }

        for (int i = 0; i < galaxie.size; i++) {
            for (int j = 0; j < galaxie.size; j++) {
                if (i != j) {
                    float dx = galaxie.posX[j] - galaxie.posX[i];
                    float dy = galaxie.posY[j] - galaxie.posY[i];
                    float dz = galaxie.posZ[j] - galaxie.posZ[i];
                    float dij = dx * dx + dy * dy + dz * dz;
                    float d3;
                    if (dij < 1.0f) {
                        d3 = 10.0f * galaxie.mass[j];
                    } else {
                        float sqrtd = (float) Math.sqrt(dij);
                        d3 = 10.0f * galaxie.mass[j] / (sqrtd * sqrtd * sqrtd);
                    }
                    accelX[i] += dx * d3;
                    accelY[i] += dy * d3;
                    accelZ[i] += dz * d3;
                }
            }
        }

        for (int i = 0; i < galaxie.size; i++) {
            galaxie.velX[i] += accelX[i] * 2.0f;
            galaxie.velY[i] += accelY[i] * 2.0f;
            galaxie.velZ[i] += accelZ[i] * 2.0f;
            galaxie.posX[i] += galaxie.velX[i] * dt;
            galaxie.posY[i] += galaxie.velY[i] * dt;
            galaxie.posZ[i] += galaxie.velZ[i] * dt;
        }
    }

    public Galaxy particules() {
        return galaxie;
    }
}
