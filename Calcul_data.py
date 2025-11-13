# -*- coding: utf-8 -*-

import argparse
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

fichier_cpp = "/home/rose/Documents/Projet_Galaxerb/cpp-naif-cli/resultats.txt"
fichier_java = "/home/rose/Documents/Projet_Galaxerb/java_naif_cli/resultats.txt"
fichier_python = "/home/rose/Documents/Projet_Galaxerb/python-naif-cli/resultats.txt"


# Libellés (légendes des courbes)
labels = ["C++", "Java", "Python"]

# Période d'échantillonnage en secondes (ex: 1.0 = 1 mesure/seconde)
periode = 0.5

# Préfixe pour les fichiers de sortie (facultatif)
prefix = "comparaison_"
# ==============================================================

def charger_donnees(fichier: Path) -> pd.DataFrame:
    df = pd.read_csv(fichier, sep="\t")
    # Nettoyage minimal : retire les espaces dans les noms, si besoin
    df.columns = [c.strip() for c in df.columns]
    # Vérif colonnes
    attendues = {"Avg_MHz", "PkgTmp", "PkgWatt"}
    manquantes = attendues - set(df.columns)
    if manquantes:
        raise ValueError(f"Colonnes manquantes dans {fichier}: {manquantes}")
    return df

def creer_axe_temps(n_points: int, periode_s: float) -> pd.Series:
    """Crée un axe temps en secondes à partir du nombre d'échantillons et d'une période d'échantillonnage."""
    # 0, 1*periode, 2*periode, ...
    return pd.Series([i * periode_s for i in range(n_points)], name="Temps (s)")

def calculer_moyennes(df: pd.DataFrame):
    freq_moy = df["Avg_MHz"].mean()
    temp_moy = df["PkgTmp"].mean()
    puiss_moy = df["PkgWatt"].mean()
    return freq_moy, temp_moy, puiss_moy

def tracer_courbes(t: pd.Series, df: pd.DataFrame, prefix: str = "courbe"):
    # 1) Fréquence
    plt.figure()
    plt.plot(t, df["Avg_MHz"])
    plt.title("Fréquence CPU en fonction du temps")
    plt.xlabel("Temps (s)")
    plt.ylabel("Fréquence (MHz)")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f"{prefix}_frequence.png", dpi=150)

    # 2) Puissance
    plt.figure()
    plt.plot(t, df["PkgWatt"])
    plt.title("Puissance CPU en fonction du temps")
    plt.xlabel("Temps (s)")
    plt.ylabel("Puissance (W)")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f"{prefix}_puissance.png", dpi=150)

    # 3) Température
    plt.figure()
    plt.plot(t, df["PkgTmp"])
    plt.title("Température CPU en fonction du temps")
    plt.xlabel("Temps (s)")
    plt.ylabel("Température (°C)")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(f"{prefix}_temperature.png", dpi=150)

    # Afficher les figures à l'écran
    plt.show()

def main():
    fichiers = [fichier_cpp, fichier_java, fichier_python]
    dfs = []
    temps = []
    i = 0
    periode = 0.5
    """  parser = argparse.ArgumentParser(description="Calcul de moyennes et tracé de courbes CPU.")
    parser.add_argument("-f", "--fichier", default="cpp-naif-cli/resultats.txt",
                        help="Chemin du fichier d'entrée (par défaut: resultats.txt)")
    parser.add_argument("-p", "--periode", type=float, default=1.0,
                        help="Période d'échantillonnage en secondes (par défaut: 1.0s)")
    parser.add_argument("--prefix", default="courbe",
                        help="Préfixe des fichiers PNG exportés (par défaut: courbe)")
    args = parser.parse_args() """
    for f in fichiers:
        fichier_Path = Path(f)
        if not Path(f).exists():
            raise FileNotFoundError(f"⚠️ Fichier introuvable : {f}")
        df = charger_donnees(fichier_Path)
        dfs.append(df)
        temps.append(creer_axe_temps(len(df), periode))

    """ 
    df = charger_donnees(fichier)
    t = creer_axe_temps(len(df), args.periode) """

    # Calcul des moyennes
    freq_moy, temp_moy, puiss_moy = calculer_moyennes(df)
    print("=== Résultats des moyennes ===")
    print(f"Fréquence moyenne : {freq_moy:.2f} MHz")
    print(f"Température moyenne : {temp_moy:.2f} °C")
    print(f"Puissance moyenne  : {puiss_moy:.2f} W")

    # Tracés
    tracer_courbes(t, df, prefix=args.prefix)

if __name__ == "__main__":
    main()
