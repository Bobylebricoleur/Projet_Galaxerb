
function galaxie = load_from_file(filename, step)
    fid = fopen(filename, 'r');
    if fid == -1
        fprintf('(EE) Error opening file (%s)\n', filename);
        error('File not found');
    end
    
    % Lecture de toutes les lignes
    lines = {};
    lineNumber = 0;
    while ~feof(fid)
        line = fgetl(fid);
        if ischar(line)
            if mod(lineNumber, step) == 0
                lines{end+1} = line;
            end
            lineNumber = lineNumber + 1;
        end
    end
    fclose(fid);
    
    if isempty(lines)
        fprintf('(EE) Error the file is empty\n');
        error('Empty file');
    end
    
    n = length(lines);
    galaxie.size = n;
    galaxie.mass = zeros(n, 1);
    galaxie.pos_x = zeros(n, 1);
    galaxie.pos_y = zeros(n, 1);
    galaxie.pos_z = zeros(n, 1);
    galaxie.vel_x = zeros(n, 1);
    galaxie.vel_y = zeros(n, 1);
    galaxie.vel_z = zeros(n, 1);
    galaxie.color = zeros(n, 1);
    
    % Parse format .tab
    for i = 1:n
        values = sscanf(lines{i}, '%f');
        galaxie.mass(i) = values(1);
        galaxie.pos_x(i) = values(2);
        galaxie.pos_y(i) = values(3);
        galaxie.pos_z(i) = values(4);
        galaxie.vel_x(i) = values(5);
        galaxie.vel_y(i) = values(6);
        galaxie.vel_z(i) = values(7);
        galaxie.color(i) = values(8);
    end
end

% Fonction de sauvegarde
function save_to_file(galaxie, filename, fmt)
    fid = fopen(filename, 'w');
    if fid == -1
        fprintf('(EE) Impossible d''ouvrir le fichier en écriture : %s\n', filename);
        return;
    end
    
    for i = 1:galaxie.size
        if strcmp(fmt, 'tab')
            fprintf(fid, '%+15.8e %+15.8e %+15.8e %+15.8e %+15.8e %+15.8e %+15.8e %6d\n', ...
                    galaxie.mass(i), galaxie.pos_x(i), galaxie.pos_y(i), galaxie.pos_z(i), ...
                    galaxie.vel_x(i), galaxie.vel_y(i), galaxie.vel_z(i), galaxie.color(i));
        end
    end
    
    fclose(fid);
    fprintf('(II) Galaxie sauvegardée dans %s (format %s)\n', filename, fmt);
end