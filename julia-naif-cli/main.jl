# --- Activate Env 
using Pkg
Pkg.activate(@__DIR__)
# --- Activate output packages 
using Printf
using Statistics
using Dates
# --- Internal packages 
include("FileTools.jl")
using .FileTools
include("RenderNaiveGen.jl")
using .RenderNaiveGen


function main()
    println("=== Simulation Julia ===")

    filename = "/home/rose/Documents/Projet_Galaxerb/data/dubinski_colored.tab"

    # Chargement des particules
    
    
    galaxy = FileTools.load_from_file(filename, 16)

    println("=== Caractéristiques de la galaxie ===")
    println("Nombre de particules : ", galaxy.size)
    println(@sprintf("Masse totale         : %.3e", sum(galaxy.mass)))
    println(@sprintf("Masse moyenne        : %.3e", mean(galaxy.mass)))

    total_mass = sum(galaxy.mass)
    center_of_mass = [
        sum(galaxy.mass .* galaxy.pos_x) / total_mass,
        sum(galaxy.mass .* galaxy.pos_y) / total_mass,
        sum(galaxy.mass .* galaxy.pos_z) / total_mass,
    ]
    println("Centre de masse      : ", center_of_mass)

    mean_velocity = [
        mean(galaxy.vel_x),
        mean(galaxy.vel_y),
        mean(galaxy.vel_z),
    ]
    println("Vitesse moyenne      : ", mean_velocity)

    # Création du moteur de rendu
    sim = RenderNaiveGen.RenderNaive(galaxy; dt=1.0)

    println("Lancement de la procedure de test")
    t0 = time()
    for ii in 1:10
        ts = time()
        RenderNaiveGen.execute(sim)
        te = time()
        println(@sprintf(" - Iteration %d : %.3f s", ii, (te - ts)/10))
    end
    t1 = time()
    println("Fin de la procedure de test")
    println(@sprintf("Temps total pour 10 itérations : %.3f s", t1 - t0))
    println(@sprintf("Temps moyen par itération      : %.3f s", (t1 - t0)/10))

    galaxy = RenderNaiveGen.particules(sim)
    FileTools.save_to_file(galaxy, "particules.out", fmt="tab")
end

main()