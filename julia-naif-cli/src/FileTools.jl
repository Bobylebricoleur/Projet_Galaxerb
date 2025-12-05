module FileTools

using Random
using Printf 
# =============================
# Définition de la structure Galaxy
# =============================
mutable struct Galaxy
    size::Int
    mass::Vector{Float64}
    pos_x::Vector{Float64}
    pos_y::Vector{Float64}
    pos_z::Vector{Float64}
    vel_x::Vector{Float64}
    vel_y::Vector{Float64}
    vel_z::Vector{Float64}
    color::Vector{Int32}
end

function create_galaxy(n::Int)::Galaxy
    Galaxy(
        n,
        zeros(Float64, n),
        zeros(Float64, n),
        zeros(Float64, n),
        zeros(Float64, n),
        zeros(Float64, n),
        zeros(Float64, n),
        zeros(Float64, n),
        zeros(Int32, n)
    )
end

# =============================
# Lecture des fichiers
# =============================
function load_tab_from_file(filename::String, step::Int)::Galaxy
    lines = readlines(filename)
    liste = [line for (i, line) in enumerate(lines) if (i-1) % step == 0]

    if isempty(liste)
        error("(EE) Error the file is empty, no particle is loaded")
    end

    data = reduce(vcat, [parse.(Float64, split(l))' for l in liste])

    g = create_galaxy(size(data, 1))
    g.mass  .= data[:, 1]
    g.pos_x .= data[:, 2]
    g.pos_y .= data[:, 3]
    g.pos_z .= data[:, 4]
    g.vel_x .= data[:, 5]
    g.vel_y .= data[:, 6]
    g.vel_z .= data[:, 7]
    g.color .= Int32.(data[:, 8])

    return g
end

function load_glx_from_file(filename::String, step::Int)::Galaxy
    lines = readlines(filename)
    liste = [line for (i, line) in enumerate(lines) if (i-1) % step == 0]

    if isempty(liste)
        error("(EE) Error the file is empty, no particle is loaded")
    end

    data = reduce(vcat, [parse.(Float64, split(l))' for l in liste])

    g = create_galaxy(size(data, 1))
    g.pos_x .= data[:, 1]
    g.pos_y .= data[:, 2]
    g.pos_z .= data[:, 3]
    g.vel_x .= data[:, 4]
    g.vel_y .= data[:, 5]
    g.vel_z .= data[:, 6]
    g.mass  .= data[:, 7]
    g.color .= Int32.(data[:, 8])

    return g
end

function load_from_file(filename::String, step::Int)::Galaxy
    if endswith(filename, ".gxy")
        return load_glx_from_file(filename, step)
    elseif endswith(filename, ".tab")
        return load_tab_from_file(filename, step)
    else
        error("(EE) The file format is not yet supported $filename")
    end
end

# =============================
# Sauvegarde
# =============================
function save_to_file(galaxy::Galaxy, filename::String; fmt::String="tab")
    open(filename, "w") do f
        for i in 1:galaxy.size
            if fmt == "tab"
                println(f,
                    @sprintf("%+15.8e %+15.8e %+15.8e %+15.8e %+15.8e %+15.8e %+15.8e %6d",
                        galaxy.mass[i], galaxy.pos_x[i], galaxy.pos_y[i], galaxy.pos_z[i],
                        galaxy.vel_x[i], galaxy.vel_y[i], galaxy.vel_z[i], galaxy.color[i]
                    )
                )
            elseif fmt == "gxy"
                println(f,
                    @sprintf("%+15.8e %+15.8e %+15.8e %+15.8e %+15.8e %+15.8e %+15.8e %6d",
                        galaxy.pos_x[i], galaxy.pos_y[i], galaxy.pos_z[i],
                        galaxy.vel_x[i], galaxy.vel_y[i], galaxy.vel_z[i],
                        galaxy.mass[i], galaxy.color[i]
                    )
                )
            else
                error("(EE) Format non supporté : $fmt")
            end
        end
    end
end

end # module