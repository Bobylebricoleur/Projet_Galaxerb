function g = render_naive_execute(g)
    N = double(g.size);
    if N == 0, return; end
    accel_x = zeros(N,1,'single');
    accel_y = zeros(N,1,'single');
    accel_z = zeros(N,1,'single');
    dt = single(0.01);
    
    for i = 1:N
        xi = g.pos_x(i); yi = g.pos_y(i); zi = g.pos_z(i);
        aix = single(0); aiy = single(0); aiz = single(0);
        for j = 1:N
            if j == i, continue; end
            dx = g.pos_x(j) - xi;
            dy = g.pos_y(j) - yi;
            dz = g.pos_z(j) - zi;
            dij = dx*dx + dy*dy + dz*dz; 
            if dij < 1.0
                d3 = single(10.0) * g.mass(j);
            else
                sqrtd = sqrt(dij);
                d3 = single(10.0) * g.mass(j) / (sqrtd * sqrtd * sqrtd);
            end
            aix = aix + dx * d3;
            aiy = aiy + dy * d3;
            aiz = aiz + dz * d3;
        end
        accel_x(i) = aix; accel_y(i) = aiy; accel_z(i) = aiz;
    end
    
    g.vel_x = g.vel_x + accel_x * single(2.0);
    g.vel_y = g.vel_y + accel_y * single(2.0);
    g.vel_z = g.vel_z + accel_z * single(2.0);
    
    
    g.pos_x = g.pos_x + g.vel_x * dt;
    g.pos_y = g.pos_y + g.vel_y * dt;
    g.pos_z = g.pos_z + g.vel_z * dt;
end