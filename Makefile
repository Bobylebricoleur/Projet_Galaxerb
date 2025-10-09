.PHONY: all cpp python clean results

all: cpp python java 

cpp:
	$(MAKE) -C cpp-naif-cli run mode=$(mode) n=$(n) t=$(t)

python:
	$(MAKE) -C python-naif-cli run mode=$(mode) n=$(n) t=$(t)

java:
	$(MAKE) -C java_naif_cli run mode=$(mode) n=$(n) t=$(t)

rust:
	cargo build --manifest-path rust-naif-cli/Cargo.toml --release

results:
	@echo "Fusion des résultats..."
	@head -n 1 results/cpp_results.csv > results/combined.csv
	@tail -n +2 results/cpp_results.csv >> results/combined.csv
	@tail -n +2 results/python_results.csv >> results/combined.csv

test:
	$(MAKE) -C cpp-naif-cli test
	$(MAKE) -C python-naif-cli test
	$(MAKE) -C java_naif_cli test
	# Ajoutez ici les tests Rust si besoin

diff : 
	$(MAKE) -C cpp-naif-cli test
	$(MAKE) -C java_naif_cli test

clean:
	$(MAKE) -C cpp clean
	rm -f results/*.csv
