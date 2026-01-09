# --- Configuration Rust ---
CARGO = cargo
# Nom du projet défini dans Cargo.toml (à vérifier)
BINARY_NAME = nbody_rust
# Chemin de l'exécutable généré en mode release
TARGET_BIN = target/release/$(BINARY_NAME)

# Flags pour égaler -march=native -O3 du C++
# RUSTFLAGS permet d'optimiser pour l'architecture locale
RUST_FLAGS = "-C target-cpu=native"

# --- Paramètres de mesure (Identiques au C++) ---
# Durée max d'exécution en secondes
DUREE = 120

# Intervalle entre deux mesures (en secondes)
INTERVALLE = 0.5

# Nom du fichier de sortie
SORTIE = resultats.txt

# Commande turbostat (avec sudo)
TURBOSTAT = sudo timeout $(DUREE) turbostat --Summary --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt --interval $(INTERVALLE) > $(SORTIE)

.PHONY: all build run test clean Experimental Diff res_conso

all: Experimental

# Compilation en mode release (optimisé)
build:
	@echo "> Compilation du projet Rust..."
	RUSTFLAGS=$(RUST_FLAGS) $(CARGO) build --release

# Lancement des mesures (Correction typo 'Experimantal' -> 'Experimental')
Experimental: build
	@echo "> Lancement de l'execution (Mode Release)..."
	./$(TARGET_BIN) -t 120 -n 16

# Cible intermédiaire si nécessaire pour make (dummy)
particules.out: Experimental
	@echo "> Fichier particules.out généré."

Diff: build
	@echo "> Lancement pour diff..."
	./$(TARGET_BIN) -i 10 -n 16
	@echo "debut de diff"
	diff particules.out ../../golden_model/particules.out
	@echo "fin de diff"

# Mesure de consommation (Lancement en parallèle)
res_conso:
	# On lance 'make all' en arrière-plan et turbostat en avant-plan
	make all & $(TURBOSTAT)

clean:
	@echo "> Nettoyage..."
	$(CARGO) clean
	rm -f particules.out
	rm -f *.txt
	rm -rf resultats/*