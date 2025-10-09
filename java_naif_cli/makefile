JAVAC = javac
JAVA = java
SRC_DIR = src
BUILD_DIR = build
SRC = $(wildcard $(SRC_DIR)/*.java)
MAIN = Main

.PHONY: all build run test clean

all: run

build:
	javac -d build src/*.java


# Usage: make run -i 10 -n 100 ou make run -t 5.0 -n 100
run: build
#java -cp build Main -i 10 -n 16
	java -cp build Main -t 120 -n 16

particules.out: run
	@echo "> Generation des particules..."

test: particules.out
	echo "debut de diff"
	diff particules.out ../golden_model/particules.out
	echo "fin de diff"

clean:
	rm -rf build/*
	rm -rf particules.out


