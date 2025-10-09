CC = g++
CFLAGS = -O2 -std=c++17
SRC = $(wildcard src/*.cpp)
TARGET = build/main


.PHONY: all build run test clean

all: run

build:
	@mkdir -p build
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC) $(LDFLAGS)
	

run: build
	@echo "> Lancement de l'execution..."
# @./build/main -i 10 -n 16 
	@./build/main -t 120 -n 16

particules.out: run
	@echo "> Generation des particules..."

test: particules.out
	echo "debut de diff"
	diff particules.out ../golden_model/particules.out
	echo "fin de diff"

clean:
	rm -rf build/*
	rm -rf particules.out
