
OCTAVE = octave --no-gui 

# Durée max d'exécution en secondes
DUREE = 120

# Intervalle entre deux mesures (en secondes)
INTERVALLE = 0.5

# Nom du fichier de sortie
SORTIE = resultats.txt

TURBOSTAT = sudo timeout $(DUREE) turbostat --Summary --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt --interval $(INTERVALLE) > $(SORTIE)

all: Experimental

build:
	@echo "No build needed for Octave"

Diff:
	$(OCTAVE) src/main.m 10 16
	echo "debut de diff"
	diff particules.out ../../golden_model/particules.out
	echo "fin de diff"

# J'ai corrigé la typo 'Experimantal' en 'Experimental'
Experimental:
	echo "> Lancement des mesures Experimental..."
#$(OCTAVE) src/main.m 
	$(OCTAVE) --eval "source('src/main.m'); main_nbody(120, 16);"
	echo "> Fin des mesures Experimental..."

res_conso:
	# Lance le calcul en arrière-plan (&) et turbostat en avant-plan
	make all & $(TURBOSTAT)

clean:
	rm -f octave-workspace
	rm -rf build/*
	rm -rf *.out
	rm -rf *.txt
	rm -rf *.csv
	rm -rf resultats/*