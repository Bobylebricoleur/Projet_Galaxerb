% Ajouter le répertoire contenant vos fonctions au path
addpath(fileparts(mfilename('load_from_file.m')));
addpath(fileparts(mfilename('load_from_file.m')));

function main()
    % Gestion des arguments
    arg_list = argv();
    nb_iterations = -1;
    temps_traitements = -1.0;
    nbParticules = -1;
    is_iteratif = false;
    is_temporel = false;
    
    % Parse arguments
    %nbParticules  = str2num(arg_list{2});
    %nb_iterations = str2num(arg_list{1});
    nbParticules  = 512;
    nb_iterations = 10;
    is_iteratif = true;
    % i = 1;
    %while i <= length(arg_list)
    %    if strcmp(arg_list{i}, '-i')
    %        nb_iterations = str2num(arg_list{i+1});
    %        is_iteratif = true;
    %        i = i + 2;
    %    elseif strcmp(arg_list{i}, '-t')
    %        temps_traitements = str2num(arg_list{i+1});
    %        is_temporel = true;
    %        i = i + 2;
    %    elseif strcmp(arg_list{i}, '-n')
    %        nbParticules = str2num(arg_list{i+1});
    %        i = i + 2;
    %    else
    %        i = i + 1;
    %    end
    %end */
    %
    if nbParticules <= 0 || (!is_iteratif && !is_temporel)
        fprintf('Usage: octave main.m -i <nb_iterations> -n <nb_particules> | -t <temps> -n <nb_particules>\n');
        return;
    end
    
    filename = "../../../data/dubinski_colored.tab";
    
    fprintf('(II) Début du chargement de la constellation\n');
    galaxie = load_from_file(filename, nbParticules);
    fprintf('(II) Fin du chargement de la constellation\n');
    disp(galaxie.size)
    cpt = 0;
    temps = 0.0;
    start_ref = tic;
    disp(galaxie.size)
    fprintf('Je suis ICI\n');
    disp(galaxie.size)
    if is_iteratif
        
        for iter = 1:nb_iterations
            start = tic;
            galaxie = RenderNaive(galaxie);
            execTime = toc(start);
            fprintf('ExecTime = %.6f sec.\n', execTime);
        end
        cpt = nb_iterations;
        temps_tot = toc(start_ref);

    elseif is_temporel
        cpt = 0;
        temps = 0.0;
        while temps <= temps_traitements
            start = tic;
            cpt = cpt + 1;
            galaxie = RenderNaive(galaxie);
            execTime = toc(start);
            temps = temps + execTime;
            fprintf('Exécution n° %d ExecTime = %.6f sec.\n', cpt, execTime);
        end
        temps_tot = toc(start_ref);
    end
    
    if galaxie.size == 0
        fprintf('(EE) Error the galaxy has no particle (g.size == %d)\n', galaxie.size);
        return;
    end
    
    % Calcul des caractéristiques
    total_mass = sum(galaxie.mass);
    sum_pos_x = sum(galaxie.mass .* galaxie.pos_x);
    sum_pos_y = sum(galaxie.mass .* galaxie.pos_y);
    sum_pos_z = sum(galaxie.mass .* galaxie.pos_z);
    
    sum_vel_x = sum(galaxie.vel_x);
    sum_vel_y = sum(galaxie.vel_y);
    sum_vel_z = sum(galaxie.vel_z);
    
    mean_mass = total_mass / galaxie.size;
    center_x = sum_pos_x / total_mass;
    center_y = sum_pos_y / total_mass;
    center_z = sum_pos_z / total_mass;
    
    mean_vel_x = sum_vel_x / galaxie.size;
    mean_vel_y = sum_vel_y / galaxie.size;
    mean_vel_z = sum_vel_z / galaxie.size;
    
    tmps_mean = temps_tot / nb_iterations;
    
    fprintf('=========================== caractéristique de la galaxie ===========================\n');
    fprintf('Nombre de particules : %d\n', galaxie.size);
    fprintf('Masse totale         : %.3e\n', total_mass);
    fprintf('Masse moyenne        : %.3e\n', mean_mass);
    fprintf('Centre de masse      : (%.3e, %.3e, %.3e)\n', center_x, center_y, center_z);
    fprintf('Vitesse moyenne      : (%.3e, %.3e, %.3e)\n', mean_vel_x, mean_vel_y, mean_vel_z);
    fprintf('=========================== ============================== ===========================\n');
    fprintf('=========================== Calculs temporels ===========================\n');
    fprintf('Temps moyen par itération : %.6f sec.\n', tmps_mean);
    fprintf('Temps total pour %d itérations : %.6f sec.\n', nb_iterations, temps_tot);
    fprintf('=========================== ============================== ===========================\n');
    
    save_to_file(galaxie, 'particules.out', 'tab');
end



