module RenderNaiveGen

using LinearAlgebra
using Dates
import ..FileTools: Galaxy

mutable struct RenderNaive
    galaxie::Galaxy
    dt::Float64
    accel_x::Vector{Float64}
    accel_y::Vector{Float64}
    accel_z::Vector{Float64}
    _elapsed::Float64
end

function RenderNaive(galaxy::Galaxy; dt::Float64=0.01)
    n = galaxy.size
    return RenderNaive(
        galaxy, dt,
        zeros(n), zeros(n), zeros(n),
        0.0
    )
end

function execute(sim::RenderNaive)
    t0 = time()

    n = sim.galaxie.size
    fill!(sim.accel_x, 0.0)
    fill!(sim.accel_y, 0.0)
    fill!(sim.accel_z, 0.0)

    for i in 1:n
        for j in 1:n
            if i != j
                dx = sim.galaxie.pos_x[j] - sim.galaxie.pos_x[i]
                dy = sim.galaxie.pos_y[j] - sim.galaxie.pos_y[i]
                dz = sim.galaxie.pos_z[j] - sim.galaxie.pos_z[i]

                dij = dx*dx + dy*dy + dz*dz

                d3 = if dij < 1.0
                    10.0 * sim.galaxie.mass[j]
                else
                    sqrtd = sqrt(dij)
                    10.0 * sim.galaxie.mass[j] / (sqrtd^3)
                end

                sim.accel_x[i] += dx * d3
                sim.accel_y[i] += dy * d3
                sim.accel_z[i] += dz * d3
            end
        end
    end

    # Mise à jour vitesses + positions
    sim.galaxie.vel_x .+= sim.accel_x .* 2.0
    sim.galaxie.vel_y .+= sim.accel_y .* 2.0
    sim.galaxie.vel_z .+= sim.accel_z .* 2.0

    sim.galaxie.pos_x .+= sim.galaxie.vel_x .* sim.dt
    sim.galaxie.pos_y .+= sim.galaxie.vel_y .* sim.dt
    sim.galaxie.pos_z .+= sim.galaxie.vel_z .* sim.dt

    sim._elapsed = time() - t0
end

function particules(sim::RenderNaive)
    return sim.galaxie
end

function fps(sim::RenderNaive)
    return sim._elapsed > 0 ? 1.0 / sim._elapsed : 0.0
end

end # module