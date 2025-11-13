JAVAC = javac
JAVA = java
SRC_DIR = src
BUILD_DIR = build
SRC = $(wildcard $(SRC_DIR)/*.java)
MAIN = Main

# Durée max d'exécution en secondes
DUREE = 120

# Intervalle entre deux mesures (en secondes)
INTERVALLE = 0.5

# Nom du fichier de sortie
SORTIE = resultats.txt

# Commande turbostat (avec sudo)
TURBOSTAT = sudo timeout $(DUREE) turbostat --Summary --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt --interval $(INTERVALLE) > $(SORTIE)

.PHONY: all build run test clean

all: run

build:
	javac -d build src/*.java


# Usage: make run -i 10 -n 100 ou make run -t 5.0 -n 100
run_jit: build
	java -cp build Main -i 10 -n 16

run: build
	java -Djava.compiler=NONE -cp build Main -i 10 -n 16

perf: build
	java -cp build Main -t 120 -n 16

particules.out: run
	@echo "> Generation des particules..."

test: particules.out
	echo "debut de diff"
	diff particules.out ../golden_model/particules.out
	echo "fin de diff"

res_conso:
	@echo "⚙️  Lancement de la mesure CPU (durée : $(DUREE)s, intervalle : $(INTERVALLE)s)..."
	make all & $(TURBOSTAT)
	@echo "✅ Mesures terminées. Résultats enregistrés dans $(SORTIE)"

clean:
	rm -rf build/*
	rm -rf particules.out


