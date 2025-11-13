# Compilateur / interpréteur
JULIA        = julia
JULIA_FLAGS  = --project=. -O2

# Sources & cible logique
SRC          = $(wildcard src/*.jl)
SCRIPT       = src/main.jl
TARGET       = build/.precompiled  # simple marqueur de build

.PHONY: all build run test clean particules.out

all: run

build: $(TARGET)

$(TARGET): $(SRC) Project.toml Manifest.toml
@mkdir -p build
@echo "> Instanciation & précompilation du projet Julia..."
@$(JULIA) --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
@touch $(TARGET)

run: build
@echo "> Lancement de l'execution..."
# Exemple proche de ton exécution C++ : -t pour threads Julia, -n passé à ton script
@$(JULIA) $(JULIA_FLAGS) -t 120 $(SCRIPT) -n 16

particules.out: run
@echo "> Generation des particules..."
# Si ton script écrit déjà particules.out, rien à faire ici.
# Sinon, ajoute une commande pour le générer.

test: particules.out
@echo "debut de diff"
@diff particules.out ../golden_model/particules.out
@echo "fin de diff"

clean:
@rm -rf build/*
@rm -f particules.out