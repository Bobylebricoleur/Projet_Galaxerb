PYTHON=python3

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

clean:
	rm -f *.pyc __pycache__/*
