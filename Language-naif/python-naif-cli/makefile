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

Diff: 
#$(PYTHON) \src/main.py -i 1 -n 16
	echo "debut de diff"
	diff particules.out ../../golden_model/particules.out
	echo "fin de diff"

Experimantal: 
	echo "> Lancement des mesures Experimantal..."
	$(PYTHON) \src/main.py -t 120 -n 16
	echo "> Fin des mesures Experimantal..."

res_conso:
	make all & $(TURBOSTAT)

clean:
	rm -f *.pyc __pycache__/*
	rm -rf build/*
	rm -rf *.out
	rm -rf *.txt
	rm -rf *.csv
	rm -rf resultats/*
