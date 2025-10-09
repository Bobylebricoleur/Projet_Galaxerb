import math
import random
import numpy as np

class Galaxy:
    def __init__(self, n: int):
        self.size  = n
        self.mass  = np.zeros(n, dtype=np.float64)
        self.pos_x = np.zeros(n, dtype=np.float64)
        self.pos_y = np.zeros(n, dtype=np.float64)
        self.pos_z = np.zeros(n, dtype=np.float64)
        self.vel_x = np.zeros(n, dtype=np.float64)
        self.vel_y = np.zeros(n, dtype=np.float64)
        self.vel_z = np.zeros(n, dtype=np.float64)
        self.color = np.zeros(n, dtype=np.int32)

def create_galaxy(n: int) -> Galaxy:
    return Galaxy(n)

def CreateGalaxy(n: int) -> Galaxy:
    g = create_galaxy(n)
    g.size = n

    random.seed(n)

    # corps central
    g.mass[0]  = 2.0e24
    g.pos_x[0] = 0.0
    g.pos_y[0] = 0.0
    g.pos_z[0] = 0.0
    g.vel_x[0] = 0.0
    g.vel_y[0] = 0.0
    g.vel_z[0] = 0.0
    g.color[0] = 200

    # les autres corps
    for iBody in range(1, n):
        mi = random.random() * 5e20
        ri = mi * 2.5e-15  # unused, mais je le garde

        horizontalAngle = random.random() * 2.0 * math.pi
        verticalAngle   = random.random() * 2.0 * math.pi
        distToCenter    = random.random() * 1.0e8 + 1.0e8

        qix = math.cos(verticalAngle) * math.sin(horizontalAngle) * distToCenter
        qiy = math.sin(verticalAngle) * distToCenter
        qiz = math.cos(verticalAngle) * math.cos(horizontalAngle) * distToCenter

        vix =  qiy * 4.0e-6
        viy = -qix * 4.0e-6
        viz =  0.0

        g.mass[iBody]  = mi
        g.pos_x[iBody] = qix
        g.pos_y[iBody] = qiy
        g.pos_z[iBody] = qiz
        g.vel_x[iBody] = vix
        g.vel_y[iBody] = viy
        g.vel_z[iBody] = viz
        g.color[iBody] = 200

    return g

def load_tab_from_file(filename: str, step: int) -> Galaxy:
    try:
        with open(filename, "r") as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"(EE) Error opening file ({filename})")
        exit(1)

    # filtre 1 ligne sur step
    liste = [line.strip() for i, line in enumerate(lines) if i % step == 0]

    if len(liste) == 0:
        print("(EE) Error the file is empty, no particle is loaded")
        exit(1)

    g = create_galaxy(len(liste))
    data = np.array([line.split() for line in liste], dtype=np.float64)

    g.mass  = data[:, 0]
    g.pos_x = data[:, 1]
    g.pos_y = data[:, 2]
    g.pos_z = data[:, 3]
    g.vel_x = data[:, 4]
    g.vel_y = data[:, 5]
    g.vel_z = data[:, 6]
    g.color = data[:, 7].astype(np.int32)

    g.size = len(liste)
    return g

def load_glx_from_file(filename: str, step: int) -> Galaxy:
    try:
        with open(filename, "r") as f:
            lines = f.readlines()
    except FileNotFoundError:
        print(f"(EE) Error opening file ({filename})")
        exit(1)

    liste = [line.strip() for i, line in enumerate(lines) if i % step == 0]

    if len(liste) == 0:
        print("(EE) Error the file is empty, no particle is loaded")
        exit(1)

    g = create_galaxy(len(liste))
    data = np.array([line.split() for line in liste], dtype=np.float64)

    g.pos_x = data[:, 0]
    g.pos_y = data[:, 1]
    g.pos_z = data[:, 2]
    g.vel_x = data[:, 3]
    g.vel_y = data[:, 4]
    g.vel_z = data[:, 5]
    g.mass  = data[:, 6]
    g.color = data[:, 7].astype(np.int32)

    g.size = len(liste)
    return g

def load_from_file(filename: str, step: int) -> Galaxy:
    if filename.endswith(".gxy"):
        return load_glx_from_file(filename, step)
    elif filename.endswith(".tab"):
        return load_tab_from_file(filename, step)
    else:
        print(f"(EE) The file format is not yet supported {filename}")
        exit(1)

def save_to_file(galaxy, filename, fmt="tab"):
    """
    Sauvegarde une galaxie dans un fichier texte.

    fmt = "tab" -> format .tab (mass, pos, vel, color)
    fmt = "gxy" -> format .gxy (pos, vel, mass, color)
    """
    with open(filename, "w") as f:
        for i in range(galaxy.size):
            if fmt == "tab":
                line = (
                    f"{galaxy.mass[i]:+15.8e} "
                    f"{galaxy.pos_x[i]:+15.8e} "
                    f"{galaxy.pos_y[i]:+15.8e} "
                    f"{galaxy.pos_z[i]:+15.8e} "
                    f"{galaxy.vel_x[i]:+15.8e} "
                    f"{galaxy.vel_y[i]:+15.8e} "
                    f"{galaxy.vel_z[i]:+15.8e} "
                    f"{galaxy.color[i]:6d}\n"
                )
            elif fmt == "gxy":
                line = (
                    f"{galaxy.pos_x[i]:+15.8e} "
                    f"{galaxy.pos_y[i]:+15.8e} "
                    f"{galaxy.pos_z[i]:+15.8e} "
                    f"{galaxy.vel_x[i]:+15.8e} "
                    f"{galaxy.vel_y[i]:+15.8e} "
                    f"{galaxy.vel_z[i]:+15.8e} "
                    f"{galaxy.mass[i]:+15.8e} "
                    f"{galaxy.color[i]:6d}\n"
                )
            else:
                raise ValueError(f"(EE) Format non supporté : {fmt}")
            f.write(line)
