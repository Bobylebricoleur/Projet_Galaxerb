# -*- coding: utf-8 -*-

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from io import StringIO

# ===================== À ADAPTER PAR TOI =====================
fichier_cpp    = "/home/rose/Documents/Projet_Galaxerb/cpp-naif-cli/resultats.txt"
fichier_java   = "/home/rose/Documents/Projet_Galaxerb/java_naif_cli/resultats.txt"
fichier_python = "/home/rose/Documents/Projet_Galaxerb/python-naif-cli/resultats.txt"

labels  = ["C++", "Java", "Python"]      # légende
periode = 0.5                             # secondes entre deux mesures
prefix  = "comparaison_"                  # préfixe des fichiers de sortie
# =============================================================


def lire_donnees_robuste(fichier: Path) -> pd.DataFrame:
    """
    Lit un fichier texte tabulaire et renvoie un DataFrame
    avec colonnes: Avg_MHz, PkgTmp, PkgWatt.
    Tolère BOM, lignes vides/commentaires, séparateurs \t, ',', ';' ou espaces,
    et l'absence d'en-tête.
    """
    if not fichier.exists():
        raise FileNotFoundError(f"Fichier introuvable: {fichier}")
    if fichier.stat().st_size == 0:
        raise ValueError(f"Fichier vide: {fichier}")

    # Nettoie les lignes vides/commentées
    with open(fichier, "r", encoding="utf-8", errors="replace") as fh:
        lignes = [ln for ln in fh.readlines() if ln.strip() and not ln.lstrip().startswith("#")]
    if not lignes:
        raise ValueError(f"Aucune donnée exploitable dans: {fichier}")

    tampon = StringIO("".join(lignes))

    essais = [
        dict(sep="\t", engine="python"),
        dict(sep=",",  engine="python"),
        dict(sep=";",  engine="python"),
        dict(delim_whitespace=True, engine="python"),
    ]
    attendues = {"Avg_MHz", "PkgTmp", "PkgWatt"}
    last_err = None

    for opts in essais:
        try:
            tampon.seek(0)
            df = pd.read_csv(tampon, encoding="utf-8-sig", **opts)
            if df.shape[1] == 0:
                continue

            cols = [c.strip() if isinstance(c, str) else c for c in df.columns]
            # Si les colonnes existent déjà par nom
            if attendues.issubset(set(cols)):
                df = df[["Avg_MHz", "PkgTmp", "PkgWatt"]]
                return df.dropna(subset=["Avg_MHz", "PkgTmp", "PkgWatt"])

            # Sinon, relire sans header et nommer les 3 premières colonnes
            tampon.seek(0)
            df = pd.read_csv(tampon, header=None, encoding="utf-8-sig", **opts)
            if df.shape[1] < 3:
                continue
            df = df.iloc[:, :3]
            df.columns = ["Avg_MHz", "PkgTmp", "PkgWatt"]
            return df.dropna(subset=["Avg_MHz", "PkgTmp", "PkgWatt"])

        except Exception as e:
            last_err = e
            continue

    raise ValueError(
        f"Impossible de lire {fichier} avec tabulation/virgule/point-virgule/espaces. "
        f"Dernière erreur: {last_err}"
    )


def creer_axe_temps(n_points: int, periode_s: float) -> pd.Series:
    return pd.Series([i * periode_s for i in range(n_points)], name="Temps (s)")


def calculer_moyennes(df: pd.DataFrame):
    freq_moy = float(df["Avg_MHz"].mean())
    temp_moy = float(df["PkgTmp"].mean())
    puiss_moy = float(df["PkgWatt"].mean())
    return freq_moy, temp_moy, puiss_moy


def tracer_graphes_superposes(temps_list, dfs, labels, prefix: str = ""):
    # 1) Température
    burn_in_seconds = 10
    plt.figure()
    for t, d, lab in zip(temps_list, dfs, labels):
        t__cut = t[ int(burn_in_seconds / periode) : ]
        plt.plot(t__cut, d["PkgTmp"], label=lab, linewidth=1.6)
    plt.title("Comparaison de la température CPU")
    plt.xlabel("Temps (s)")
    plt.ylabel("Température (°C)")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig(f"{prefix}temperature.png", dpi=150)

    # 2) Puissance
    plt.figure()
    for t, d, lab in zip(temps_list, dfs, labels):
        t__cut = t[ int(burn_in_seconds / periode) : ]
        plt.plot(t__cut, d["PkgWatt"], label=lab, linewidth=1.6)
    plt.title("Comparaison de la puissance CPU")
    plt.xlabel("Temps (s)")
    plt.ylabel("Puissance (W)")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig(f"{prefix}puissance.png", dpi=150)

    # 3) Fréquence
    plt.figure()
    for t, d, lab in zip(temps_list, dfs, labels):
        t__cut = t[ int(burn_in_seconds / periode) : ]
        plt.plot(t__cut, d["Avg_MHz"], label=lab, linewidth=1.6)
    plt.title("Comparaison de la fréquence CPU")
    plt.xlabel("Temps (s)")
    plt.ylabel("Fréquence (MHz)")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig(f"{prefix}frequence.png", dpi=150)

    plt.show()


def main():
    fichiers = [Path(fichier_cpp), Path(fichier_java), Path(fichier_python)]
    dfs = []
    temps_list = []

    # Lecture robuste des 3 fichiers
    for f in fichiers:
        df = lire_donnees_robuste(f)
        dfs.append(df)
        temps_list.append(creer_axe_temps(len(df), periode))

    # Récap moyennes par fichier
    resume = []
    for lab, df in zip(labels, dfs):
        freq_m, temp_m, puiss_m = calculer_moyennes(df)
        resume.append({
            "Serie": lab,
            "Freq_moy_MHz": round(freq_m, 3),
            "Temp_moy_C": round(temp_m, 3),
            "Puiss_moy_W": round(puiss_m, 3),
            "Nb_points": len(df),
        })

    resume_df = pd.DataFrame(resume, columns=["Serie", "Freq_moy_MHz", "Temp_moy_C", "Puiss_moy_W", "Nb_points"])
    print("\n=== Moyennes par fichier ===")
    print(resume_df.to_string(index=False))
    resume_df.to_csv(f"{prefix}resume_moyennes.csv", index=False)
    print(f"\nRésumé exporté dans : {prefix}resume_moyennes.csv")

    # Graphes superposés
    tracer_graphes_superposes(temps_list, dfs, labels, prefix=prefix)


if __name__ == "__main__":
    main()
