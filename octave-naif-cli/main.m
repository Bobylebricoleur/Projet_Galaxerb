function main(args)
    g = load_from_file(infile, 1);
    else
    g = CreateGalaxy(nbParticules);
    end
    
    
    # Boucle de simulation
    if is_iteratif
    start_ref = tic();
    for k = 1:nb_iterations
    g = render_naive_execute(g);
    end
    end_ref = toc(start_ref);
    else
    cpt = 0; temps = 0.0;
    while temps <= temps_traitements
    t0 = tic();
    cpt = cpt + 1;
    g = render_naive_execute(g);
    execTime = toc(t0);
    temps = temps + execTime;
    printf('Exécution n° %d ExecTime = %.6f sec.\n', cpt, execTime);
    end
    nb_iterations = cpt;
    end_ref = temps; # total mesuré
    end
    
    
    # Caractéristiques (comme le C++)
    total_mass = sum(double(g.mass));
    center_x = sum(double(g.mass).*double(g.pos_x)) / total_mass;
    center_y = sum(double(g.mass).*double(g.pos_y)) / total_mass;
    center_z = sum(double(g.mass).*double(g.pos_z)) / total_mass;
    mean_mass = total_mass / double(g.size);
    
    
    mean_vel_x = mean(double(g.vel_x));
    mean_vel_y = mean(double(g.vel_y));
    mean_vel_z = mean(double(g.vel_z));
    
    
    tmps_tot = end_ref; # secondes
    tmps_mean = tmps_tot / nb_iterations;
    
    
    printf('=========================== Caractéristiques ===========================\n');
    printf('Nombre de particules : %d\n', g.size);
    printf('Masse totale : %.6e\n', total_mass);
    printf('Masse moyenne : %.6e\n', mean_mass);
    printf('Centre de masse : (%.6e, %.6e, %.6e)\n', center_x, center_y, center_z);
    printf('Vitesse moyenne : (%.6e, %.6e, %.6e)\n', mean_vel_x, mean_vel_y, mean_vel_z);
    printf('=========================== Calculs temporels ===========================\n');
    printf('Temps moyen par itération : %.6f sec.\n', tmps_mean);
    printf('Temps total pour %d itérations : %.6f sec.\n', nb_iterations, tmps_tot);
    
    
    # Sauvegardes (comme C++)
    save_to_file(g, 'particules.out', 'tab');
    if ~exist('results','dir'), mkdir('results'); end
    out = fullfile('results','octave_results.csv');
    append_header = ~exist(out,'file');
    fid = fopen(out,'a');
    if fid < 0, error('Cannot open results file for append'); end
    if append_header
    fprintf(fid,'lang,mode,nb_particules,total_mass,mean_mass,center_x,center_y,center_z,mean_vel_x,mean_vel_y,mean_vel_z,tmps_mean,tmps_total,caracteristiques,calculs_temporels\n');
    end
    if is_iteratif, mode = 'iteration'; else, mode = 'temporel'; end
    carac = sprintf('Nombre de particules : %d; Masse totale : %.6e; Masse moyenne : %.6e; Centre de masse : (%.6e, %.6e, %.6e); Vitesse moyenne : (%.6e, %.6e, %.6e)',...
    g.size,total_mass,mean_mass,center_x,center_y,center_z,mean_vel_x,mean_vel_y,mean_vel_z);
    temp = sprintf('Temps moyen par itération : %.6f sec.; Temps total : %.6f sec.', tmps_mean, tmps_tot);
    fprintf(fid,'octave,%s,%d,%.8e,%.8e,%.8e,%.8e,%.8e,%.8e,%.8e,%.8e,%.8f,%.8f,"%s","%s"\n',...
    mode, g.size, total_mass, mean_mass, center_x, center_y, center_z, mean_vel_x, mean_vel_y, mean_vel_z, tmps_mean, tmps_tot, carac, temp);
    fclose(fid);
    end