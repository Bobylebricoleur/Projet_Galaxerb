CC = g++
CFLAGS = -O3 -march=native -mtune=native -std=c++17
SRC = $(wildcard src/*.cpp)
TARGET = build/main

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
	@mkdir -p build
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)
	

run: build
	@echo "> Lancement de l'execution..."
#	@./build/main -i 10 -n 16 
	@./build/main -t 120 -n 16

perf: build
	@echo "> Lancement de l'execution..."
#	@./build/main -i 10 -n 16 
	@./build/main -t 120 -n 16

particules.out: run
	@echo "> Generation des particules..."

test: particules.out
	echo "debut de diff"
	diff particules.out ../golden_model/particules.out
	echo "fin de diff"

Res: run
	@echo "> Generation des particules..."


res_conso:
	make all & $(TURBOSTAT)


clean:
	rm -rf build/*
	rm -rf particules.out
