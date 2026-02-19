.PHONY: all cpp python clean results


Trace_courbes : 
	python3 Trace_courbes.py


clean:
	$(MAKE) -C Language-naif/cpp-naif-cli clean
	$(MAKE) -C Language-naif/java-naif-cli clean
	$(MAKE) -C Language-naif/julia-naif-cli clean
	$(MAKE) -C Language-naif/octave-naif-cli clean
	$(MAKE) -C Language-naif/python-naif-cli clean
	$(MAKE) -C Language-naif/rust-naif-cli clean
	$(MAKE) -C Language-opti/cpp-opti clean
	$(MAKE) -C Language-opti/cpp-opti2 clean
	$(MAKE) -C Language-opti/cpp-opti3 clean
	rm -f Resultats/*
	@echo " Nettoyage complété !"
