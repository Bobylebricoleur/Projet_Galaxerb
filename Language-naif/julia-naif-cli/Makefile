# Compilateur / interpréteur
JULIA        = julia
JULIA_FLAGS  = --project=. -O2

# Sources & cible logique
SRC          = $(wildcard src/*.jl)
SCRIPT       = src/main.jl
TARGET       = build/.precompiled  # simple marqueur de build

DUREEMESURE = 120
nb_itération = 10
Nb_particules = 16
INTERVALLE = 0.5
SORTIE = resultats.txt
TURBOSTAT = sudo timeout $(DUREEMESURE) turbostat --Summary --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt --interval $(INTERVALLE) > $(SORTIE)


.PHONY: all build run test clean particules.out


all: Experimantal

build: $(TARGET) 
	@mkdir -p build
	$(TARGET): $(SRC) src/Project.toml
	@echo "> Instanciation & précompilation du projet Julia..."
	@$(JULIA) --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
	@touch $(TARGET)

Experimantal:
	@echo "> Lancement de l'execution..."
	@$(JULIA) $(JULIA_FLAGS) $(SCRIPT) -t $(DUREEMESURE) -n $(Nb_particules)

Diff: 
	@$(JULIA) $(JULIA_FLAGS) $(SCRIPT) -i $(nb_itération) -n $(Nb_particules) > particules.out
	@echo "debut de diff"
	@diff particules.out ../../golden_model/particules.out
	@echo "fin de diff"

res_conso:
	make all & $(TURBOSTAT)

clean:
	@rm -rf build/*
	@rm -f particules.out
	rm -f *.pyc __pycache__/*
	rm -rf build/*
	rm -rf *.out
	rm -rf *.txt
	rm -rf *.csv
	rm -rf resultats/*