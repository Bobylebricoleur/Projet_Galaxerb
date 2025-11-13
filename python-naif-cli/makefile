PYTHON=python3

# Durée max d'exécution en secondes
DUREE = 120

# Intervalle entre deux mesures (en secondes)
INTERVALLE = 0.5

# Nom du fichier de sortie
SORTIE = resultats.txt

# Commande turbostat (avec sudo)
TURBOSTAT = sudo timeout $(DUREE) turbostat --Summary --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt --interval $(INTERVALLE) > $(SORTIE)

all: run

build:
	@echo "No build needed for Python"

test: run
	echo "debut de diff"
	diff particules.out golden_model\particules.out
	echo "fin de diff"

run: 
#$(PYTHON) \src/main.py -t 60 -n 16
	$(PYTHON) \src/main.py -t 120 -n 16

res_conso:
	make all & $(TURBOSTAT)

clean:
	rm -f *.pyc __pycache__/*
