import numpy as np
import time

class RenderNaive:
    def __init__(self, galaxy, dt=0.01):
        self.galaxie = galaxy
        self.dt = dt

        self.accel_x = np.zeros(galaxy.size, dtype=np.float64)
        self.accel_y = np.zeros(galaxy.size, dtype=np.float64)
        self.accel_z = np.zeros(galaxy.size, dtype=np.float64)

        self._start_time = None
        self._elapsed = 0.0

    def startExec(self):
        self._start_time = time.perf_counter()

    def stopExec(self):
        if self._start_time is not None:
            self._elapsed = time.perf_counter() - self._start_time
            self._start_time = None

    def fps(self):
        """Retourne les frames par seconde mesurées"""
        if self._elapsed > 0:
            return 1.0 / self._elapsed
        return 0.0

    def execute(self):
        self.startExec()

        # reset accélérations
        self.accel_x.fill(0.0)
        self.accel_y.fill(0.0)
        self.accel_z.fill(0.0)

        n = self.galaxie.size

        # calcul naïf des forces gravitationnelles
        for i in range(n):
            for j in range(n):
                if i != j:
                    dx = self.galaxie.pos_x[j] - self.galaxie.pos_x[i]
                    dy = self.galaxie.pos_y[j] - self.galaxie.pos_y[i]
                    dz = self.galaxie.pos_z[j] - self.galaxie.pos_z[i]

                    dij = dx*dx + dy*dy + dz*dz

                    if dij < 1.0:
                        d3 = 10.0 * self.galaxie.mass[j]  # cas proche
                    else:
                        sqrtd = np.sqrt(dij)
                        d3 = 10.0 * self.galaxie.mass[j] / (sqrtd**3)

                    self.accel_x[i] += dx * d3
                    self.accel_y[i] += dy * d3
                    self.accel_z[i] += dz * d3

        # mise à jour vitesses + positions
        self.galaxie.vel_x += self.accel_x * 2.0
        self.galaxie.vel_y += self.accel_y * 2.0
        self.galaxie.vel_z += self.accel_z * 2.0

        self.galaxie.pos_x += self.galaxie.vel_x * self.dt
        self.galaxie.pos_y += self.galaxie.vel_y * self.dt
        self.galaxie.pos_z += self.galaxie.vel_z * self.dt

        self.stopExec()

    def particules(self):
        return self.galaxie
