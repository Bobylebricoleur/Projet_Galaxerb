OCTAVE = octave 

DUREE = 120
INTERVALLE = 0.5
SORTIE = resultats.txt

TURBOSTAT = sudo timeout $(DUREE) turbostat --Summary --quiet \
	--show Busy%,Avg_MHz,PkgTmp,PkgWatt \
	--interval $(INTERVALLE) > $(SORTIE)

.PHONY: all diff experimental clean res_conso build

all: experimental

build:
	@echo "No build needed for Octave"

diff:
	$(OCTAVE) src/main.m 10 16
	echo "debut de diff"
	diff particules.out ../../golden_model/particules.out
	echo "fin de diff"

experimental:
	@echo "> Lancement des mesures Experimental..."
	@env -i PATH=/usr/bin:/bin octave src/main.m
	echo "> Lancement des mesures Experimental..."
	$(OCTAVE) src/main.m  
	echo "> Fin des mesures Experimental..."

res_conso:
	make all & $(TURBOSTAT)

clean:
	rm -f octave-workspace
	rm -rf build/*
	rm -rf *.out *.txt *.csv
	rm -rf resultats/*
