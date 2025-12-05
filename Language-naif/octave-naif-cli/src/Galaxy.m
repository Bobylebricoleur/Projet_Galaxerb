function g = Galaxy(n)
    if nargin < 1, n = 0; end
    g.size = int32(n);
    g.pos_x = zeros(n,1,'single');
    g.pos_y = zeros(n,1,'single');
    g.pos_z = zeros(n,1,'single');
    g.vel_x = zeros(n,1,'single');
    g.vel_y = zeros(n,1,'single');
    g.vel_z = zeros(n,1,'single');
    g.pos_x_new = zeros(n,1,'single');
    g.pos_y_new = zeros(n,1,'single');
    g.pos_z_new = zeros(n,1,'single');
    g.mass = zeros(n,1,'single');
    g.color = zeros(n,1,'int8');
end
    
    
function g = galaxy_update(g)
    g.pos_x = g.pos_x_new;
    g.pos_y = g.pos_y_new;
    g.pos_z = g.pos_z_new;
end
    
    
function v = min_mass(g)
    v = min(g.mass);
end

function v = max_mass(g)
    v = max(g.mass);
end
    
function v = min_x(g), v = min(g.pos_x); end
function v = min_y(g), v = min(g.pos_y); end
function v = min_z(g), v = min(g.pos_z); end
function v = max_x(g), v = max(g.pos_x); end
function v = max_y(g), v = max(g.pos_y); end
function v = max_z(g), v = max(g.pos_z); end
    
    
function v = min_xyz(g)
    v = min([min_x(g), min_y(g), min_z(g)]);
end

function v = max_xyz(g)
    v = max([max_x(g), max_y(g), max_z(g)]);
end