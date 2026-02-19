# Guide étudiant – Projet 3A

## Benchmarking multi-langages d’un simulateur de galaxies
## Profs encadrant : 
M.Le Gal et M.Gerzaguet chercheurs et ensaignants à l'ENSSAT

---

## 1. Objectifs pédagogiques

Ce projet a pour but de vous initier :

* Aux **problématiques de performance et d’efficacité énergétique** en calcul scientifique.
* A la **comparaison de plusieurs langages** (C++, Python, Julia, Java, Octave, etc.) pour un même algorithme.
* A l’**utilisation d’outils d’automatisation** (Makefile). 
* A l’usage raisonné des **LLMs (IA génératives)** comme aide à la programmation.

Le support expérimental est un **simulateur de galaxies** basé sur le calcul des interactions gravitationnelles entre particules.

---

## 2. Problématique scientifique

Le simulateur repose sur un algorithme naïf  :

* chaque particule interagit avec toutes les autres ;
* la complexité est en (O(N^2)) ;
* les performances dépendent fortement :

  * du langage,
  * du compilateur ou interpréteur,
  * de l’architecture matérielle.

L’objectif est de **mesurer et comparer** :

* le temps d’exécution ;
* la consommation énergétique (selon la plateforme) ;
* l’efficacité calcul / énergie.

---

## 3. Description du projet

### 3.1 Structure du code (version C++)

Les fichiers principaux sont :

* `FileTools.hpp` :

  * gestion des fichiers d’entrée/sortie ;
  * lecture/écriture des résultats.

* `Galaxy.hpp` :

  * définition des structures de données (particules, galaxies).

* `RenderNaive.hpp` :

  * implémentation de l’algorithme naïf de calcul des forces.

* `Main.cpp` :

  * point d’entrée du programme ;
  * orchestration des modules.

Les autres langages implémentent **exactement la même logique algorithmique (sauf exeption du au langages)**.

---

## 4. Organisation du dépôt

L’arborescence type du projet est la suivante :

```
Langage-naif-cli/
├── build/          # Fichiers compilés / exécutables
├── resultats/      # Fichiers de sortie et mesures
├── src/            # Codes sources
│   ├── Main.cpp
│   ├── Galaxy.hpp
│   ├── RenderNaive.hpp
│   └── FileTools.hpp
├── Makefile
└── README.md
```

Chaque langage possède une organisation équivalente afin de garantir la comparabilité.

---

## 5. Utilisation du Makefile

Le **Makefile** est l’outil central pour :

* compiler
* exécuter 
* analyser 
* nettoyer le projet

### 5.1 Commandes disponibles

#### `make build`

* Compile le projet si nécessaire.
* Vérifie les dépendances.
* Génère les exécutables dans le dossier `build/`.

Utilisation :

```
make build
```

---

#### `make experimental`

* Lance le programme selon le protocole expérimental.
* Exécute les simulations.
* Génère les fichiers de résultats.

Utilisation :

```
make experimental
```

---

#### `make diff`

* Compare les sorties entre le langage de référence et celui qu'on execute.
* Permet de vérifier la **validité scientifique** des résultats.

Utilisation :

```
make diff
```

---

#### `make clean`

* Supprime les fichiers générés par la compilation.
* Réinitialise le projet.

Utilisation :

```
make clean
```

---

## 6. Protocole expérimental

Deux modes sont utilisés :

### 6.1 Mode vérification

* Vérification de la cohérence des résultats numériques.
* Comparaison des sorties entre langages.

### 6.2 Mode mesures

* Exécution longue (≈ 120 secondes).
* Mesure :

  * temps par itération ;
  * consommation énergétique (si disponible).

Les mesures doivent être répétées afin de réduire le bruit expérimental.

---

## 7. Plateformes testées

Exemples de plateformes utilisées :

* Raspberry Pi 4 (Ubuntu, ARM Cortex-A72) ;
* PC laboratoire (Kubuntu, capteurs énergie) ;
* Jetson (Ubuntu 22.04, ARM) ;
* PC personnel (Ubuntu 24.02, Intel i5, GPU Nvidia).

NB : La plateforme influence les **temps absolus**, mais pas nécessairement la **hiérarchie des langages**.

---

## 8. Utilisation des LLMs (IA génératives)

### Avantages

* explication rapide de code ;
* aide au débogage ;
* retranscription multi-langages ;
* gain de temps.

### Limites

* prompts parfois inefficaces ;
* mauvaise interprétation des résultats ;
* répétitions ;
* risque de confiance excessive.

👉 Les LLMs doivent être utilisés comme **outil d’assistance**, pas comme source unique de vérité.

---

## 9. Travail demandé aux étudiants

Selon le niveau du cours, il pourra vous être demandé de :

* Comprendre et expliquer l’algorithme naïf.
* Exécuter le projet sur une plateforme donnée.
* Comparer deux langages. 
* Analyser les performances et l’énergie. 
* Documenter vos résultats.

---

## 10. Conclusion

Ce projet sert de **fil rouge pédagogique** pour aborder :

* performance logicielle ;
* efficacité énergétique ;
* méthodologie expérimentale ;
* automatisation ;
* esprit critique face aux résultats.

Il constitue une base évolutive vers :

* des algorithmes optimisés ;
* des plateformes hétérogènes ;
* des protocoles expérimentaux plus avancés.

---

**Auteur du projet** : Alexandre Victoire
**Encadrement** : Bertrand Le Gal, Robin Gerzaguet
**Contexte** : Projet Technologique 3A
