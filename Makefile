.PHONY: all cpp python clean results

all: java cpp python  
DIRS = cpp-naif-cli java_naif_cli python-naif-cli
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
	$(MAKE) -C java_naif_cli test
	$(MAKE) -C cpp-naif-cli test
	$(MAKE) -C python-naif-cli test
	# Ajoutez ici les tests Rust si besoin

diff : 
	$(MAKE) -C cpp-naif-cli test
	$(MAKE) -C java_naif_cli test

res_conso:

	@echo "🚀 Lancement des mesures CPU pour tous les langages..."
	@for dir in $(DIRS); do \
		echo "\n📂 Traitement de $$dir ..."; \
		$(MAKE) -C $$dir res_conso || exit 1; \
	done
	@echo "\n✅ Toutes les mesures sont terminées !"


clean:
	$(MAKE) -C cpp clean
	rm -f results/*.csv
