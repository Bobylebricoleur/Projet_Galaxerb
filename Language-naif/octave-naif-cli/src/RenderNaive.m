function galaxie = RenderNaive(galaxie)
    dt = 0.01;
    n = galaxie.size;
    
    accel_x = zeros(n, 1);
    accel_y = zeros(n, 1);
    accel_z = zeros(n, 1);
    
    % Calcul des accélérations
    for i = 1:n
        for j = 1:n
            if i ~= j
                dx = galaxie.pos_x(j) - galaxie.pos_x(i);
                dy = galaxie.pos_y(j) - galaxie.pos_y(i);
                dz = galaxie.pos_z(j) - galaxie.pos_z(i);
                
                dij = dx * dx + dy * dy + dz * dz;
                
                if dij < 1.0
                    d3 = 10.0 * galaxie.mass(j);
                else
                    sqrtd = sqrt(dij);
                    d3 = 10.0 * galaxie.mass(j) / (sqrtd * sqrtd * sqrtd);
                end
                
                accel_x(i) = accel_x(i) + (dx * d3);
                accel_y(i) = accel_y(i) + (dy * d3);
                accel_z(i) = accel_z(i) + (dz * d3);
            end
        end
    end
    
    % Mise à jour des vitesses et positions
    galaxie.vel_x = galaxie.vel_x + (accel_x * 2.0);
    galaxie.vel_y = galaxie.vel_y + (accel_y * 2.0);
    galaxie.vel_z = galaxie.vel_z + (accel_z * 2.0);
    
    galaxie.pos_x = galaxie.pos_x + (galaxie.vel_x * dt);
    galaxie.pos_y = galaxie.pos_y + (galaxie.vel_y * dt);
    galaxie.pos_z = galaxie.pos_z + (galaxie.vel_z * dt);
end