CC = "g++";
CFLAGS = "-O3 -march=native -mtune=native -std=c++17";
LDFLAGS = "";
SRC_DIR = "src";
TARGET_DIR = "build";
TARGET = [TARGET_DIR "/main"]; % build/main

% Variables pour la cible 'res_conso' (turbostat)
DUREE = 120;
INTERVALLE = 0.5;
SORTIE = "resultats.txt";
TURBOSTAT_CMD = ["sudo timeout " num2str(DUREE) " turbostat --Summary --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt --interval " num2str(INTERVALLE) " > " SORTIE];


% ----------------------------------------------------------------------
% FONCTIONS (Équivalent des cibles du Makefile)
% ----------------------------------------------------------------------

function build(CC, CFLAGS, LDFLAGS, TARGET, SRC_DIR)
    % Cible 'build': Crée le répertoire et compile le programme C++.
    
    % Créer le répertoire de sortie
    disp("> Création du répertoire 'build' si nécessaire...");
    system("mkdir -p build");
    
    % Trouver les fichiers sources (.cpp)
    src_files = system(["find " SRC_DIR " -name '*.cpp'"], "-echo");
    
    if (isempty(src_files))
        disp("  (EE) Aucun fichier source (.cpp) trouvé dans " + SRC_DIR);
        return;
    end
    
    % Commande de compilation
    compilation_cmd = [CC " " CFLAGS " -o " TARGET " " src_files LDFLAGS];
    
    disp("> Compilation C++...");
    disp(["  Commande: " compilation_cmd]);
    
    % Exécuter la compilation
    status = system(compilation_cmd);
    
    if (status != 0)
        disp("  (EE) Erreur de compilation.");
    else
        disp("  (II) Compilation réussie: " + TARGET);
    end
end


function Experimantal(TARGET)
    % Cible 'Experimantal': Exécute le programme avec les paramètres de la mesure.
    
    cmd = [TARGET " -t 120 -n 16"];
    disp("> Lancement de l'execution..."); 
    disp(["  Commande: " cmd]);
    
    status = system(cmd);
    
    if (status != 0)
        disp("  (EE) Erreur lors de l'exécution de Experimantal.");
    else
        disp("  (II) Exécution Experimantal terminée.");
    end
end


function Diff(TARGET)
    % Cible 'Diff': Génère les particules.out et compare au modèle de référence.
    
    GOLDEN_MODEL_PATH = "../../golden_model/particules.out";
    OUTPUT_FILE = "particules.out";
    
    % Génération de particules.out
    cmd_gen = [TARGET " -i 10 -n 16"];
    disp("> Generation des particules.out pour la comparaison...");
    disp(["  Commande: " cmd_gen]);
    status_gen = system(cmd_gen);

    if (status_gen != 0)
        disp("  (EE) Échec de la génération de particules.out.");
        return;
    end
    
    % Exécuter la commande diff
    cmd_diff = ["diff " OUTPUT_FILE " " GOLDEN_MODEL_PATH];
    disp("debut de diff");
    
    % Utilisez '-echo' pour afficher le résultat de diff directement dans la console Octave
    status_diff = system(cmd_diff, "-echo"); 
    
    if (status_diff != 0)
        disp("  (WW) Fichiers différents. Voir la sortie ci-dessus.");
    else
        disp("  (II) Fichiers identiques.");
    end
    
    disp("fin de diff");
end


function res_conso(TARGET, TURBOSTAT_CMD)
    % Cible 'res_conso': Lance l'exécution C++ en arrière-plan et turbostat.
    
    % Exécution en arrière-plan (equivalent de 'make all &')
    cmd_exec = [TARGET " -t 120 -n 16 &"]; % Le '&' met en arrière-plan

    disp("> Lancement du programme C++ en arrière-plan...");
    disp(["  Commande C++: " cmd_exec]);
    system(cmd_exec);
    
    % Lancement de turbostat
    disp("> Lancement de turbostat (nécessite sudo)...");
    disp(["  Commande turbostat: " TURBOSTAT_CMD]);
    system(TURBOSTAT_CMD);
    
    disp("  (II) Résultats de consommation sauvegardés dans resultats.txt.");
    disp("  (II) Le processus C++ pourrait encore s'exécuter si turbostat s'est terminé plus tôt.");
end


function cleanup()
    % Cible 'clean': Supprime les fichiers générés.
    disp("> Nettoyage des fichiers...");
    system("rm -rf build/*");
    system("rm -rf particules.out");
    system("rm -rf *.txt");
    system("rm -rf resultats/*");
    disp("  (II) Nettoyage terminé.");
end


% ----------------------------------------------------------------------
% LOGIQUE PRINCIPALE (Équivalent de la cible 'all')
% ----------------------------------------------------------------------
% Pour exécuter ceci:
% 1. Enregistrez le script sous 'run_tasks.m'
% 2. Lancez Octave
% 3. Exécutez: tasks('all')

function tasks(target_name)
    
    % Récupérer les variables globales pour les fonctions
    global CC CFLAGS LDFLAGS TARGET_DIR TARGET SRC_DIR DUREE INTERVALLE SORTIE TURBOSTAT_CMD;

    % Initialisation des variables globales
    CC = "g++";
    CFLAGS = "-O3 -march=native -mtune=native -std=c++17";
    LDFLAGS = "";
    SRC_DIR = "src";
    TARGET_DIR = "build";
    TARGET = [TARGET_DIR "/main"];

    DUREE = 120;
    INTERVALLE = 0.5;
    SORTIE = "resultats.txt";
    TURBOSTAT_CMD = ["sudo timeout " num2str(DUREE) " turbostat --Summary --quiet --show Busy%,Avg_MHz,PkgTmp,PkgWatt --interval " num2str(INTERVALLE) " > " SORTIE];

    
    switch(target_name)
        case 'all'
            disp("--- Cible: all -> Experimantal ---");
            build(CC, CFLAGS, LDFLAGS, TARGET, SRC_DIR);
            Experimantal(TARGET);
            
        case 'build'
            disp("--- Cible: build ---");
            build(CC, CFLAGS, LDFLAGS, TARGET, SRC_DIR);

        case 'run' % Cible non définie dans le makefile, mais utile
            disp("--- Cible: run ---");
            Experimantal(TARGET);
            
        case 'Experimantal'
            disp("--- Cible: Experimantal ---");
            Experimantal(TARGET);
            
        case 'Diff'
            disp("--- Cible: Diff ---");
            Diff(TARGET);
            
        case 'res_conso'
            disp("--- Cible: res_conso ---");
            % Note: En Octave, nous devons d'abord nous assurer que 'main' est construit.
            build(CC, CFLAGS, LDFLAGS, TARGET, SRC_DIR);
            res_conso(TARGET, TURBOSTAT_CMD);

        case 'clean'
            disp("--- Cible: clean ---");
            cleanup();
            
        otherwise
            disp(["(EE) Cible non reconnue: " target_name]);
    end
end

% Exemple d'utilisation:
% tasks('all'); 
% Pour lancer, tapez simplement 'tasks('all')' dans la console Octave
```
eof

### Comment l'utiliser dans Octave

1.  Enregistrez le code ci-dessus sous le nom `run_tasks.m`.
2.  Démarrez Octave dans le répertoire racine de votre projet.
3.  Pour lancer l'équivalent de `make Experimantal` (qui compile et exécute) :
    ```octave
    tasks('all')
    ```
4.  Pour lancer l'équivalent de `make Diff` :
    ```octave
    tasks('Diff')
    ```
5.  Pour lancer l'équivalent de `make clean` :
    ```octave
    tasks('clean')