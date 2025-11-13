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
SORTIEJIT = resultatsJit.txt

# Commande turbostat (avec sudo)
TURBOSTAT = sudo timeout $(DUREE) turbostat --Summary --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt --interval $(INTERVALLE) > $(SORTIE)
TURBOSTATJIT = sudo timeout $(DUREE) turbostat --Summary --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt --interval $(INTERVALLE) > $(SORTIEJIT)

.PHONY: all build run test clean

all: run

build:
	javac -d build src/*.java


run_jit: build
	java -cp build Main -t 120 -n 16

run: build
	java -Djava.compiler=NONE -cp build Main -t 120 -n 16

dif_jit: build
	java -cp build Main -i 10 -n 16

dif: build
	java -Djava.compiler=NONE -cp build Main -i 10 -n 16


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

res_consoJit:
	@echo "⚙️  Lancement de la mesure CPU (durée : $(DUREE)s, intervalle : $(INTERVALLE)s)..."
	make run_jit & $(TURBOSTATJIT)
	@echo "✅ Mesures terminées. Résultats enregistrés dans $(SORTIEJIT)"

clean:
	rm -rf build/*
	rm -rf particules.out


