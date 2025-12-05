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

function parse_args()
    nb_iterations = -1
    temps_traitements = -1.0
    nbParticules = -1
    is_iteratif = false
    is_temporel = false

    i = 1
    while i <= length(ARGS)
        arg = ARGS[i]
        if arg == "-i" && i + 1 <= length(ARGS)
            nb_iterations = tryparse(Int, ARGS[i+1]) === nothing ? -1 : parse(Int, ARGS[i+1])
            is_iteratif = true
            i += 2
        elseif arg == "-t" && i + 1 <= length(ARGS)
            temps_traitements = tryparse(Float64, ARGS[i+1]) === nothing ? -1.0 : parse(Float64, ARGS[i+1])
            is_temporel = true
            i += 2
        elseif arg == "-n" && i + 1 <= length(ARGS)
            nbParticules = tryparse(Int, ARGS[i+1]) === nothing ? -1 : parse(Int, ARGS[i+1])
            i += 2
        else
            @error "Usage: julia main.jl -i <nb_iterations> -n <nb_particules> | -t <temps> -n <nb_particules>"
            exit(1)
        end
    end

    if nbParticules <= 0 || (!is_iteratif && !is_temporel)
        @error "Usage: julia main.jl -i <nb_iterations> -n <nb_particules> | -t <temps> -n <nb_particules>"
        exit(1)
    end

    return (nb_iterations, temps_traitements, nbParticules, is_iteratif, is_temporel)
end

function take_first(g::FileTools.Galaxy, n::Int)
    n = min(n, g.size)
    ng = FileTools.create_galaxy(n)
    ng.mass[1:n] = g.mass[1:n]
    ng.pos_x[1:n] = g.pos_x[1:n]
    ng.pos_y[1:n] = g.pos_y[1:n]
    ng.pos_z[1:n] = g.pos_z[1:n]
    ng.vel_x[1:n] = g.vel_x[1:n]
    ng.vel_y[1:n] = g.vel_y[1:n]
    ng.vel_z[1:n] = g.vel_z[1:n]
    ng.color[1:n] = g.color[1:n]
    return ng
end

function main()
    nb_iterations, temps_traitements, nbParticules, is_iteratif, is_temporel = parse_args()

    filename = "../../data/dubinski_colored.tab"

    println("(II) Début du chargement de la constellation")
    #g_all = FileTools.load_from_file(filename, nbParticules)  # load full file (step=1)
    #galaxie = (nbParticules > 0 && nbParticules < g_all.size) ? take_first(g_all, nbParticules) : g_all
    
    galaxie = FileTools.load_from_file(filename, nbParticules)
    println("(II) Fin du chargement de la constellation")

    if galaxie.size == 0
        @error "(EE) Error the galaxy has no particle (g.size == $(galaxie.size))"
        exit(1)
    end

    cpt = 0
    temps = 0.0
    start_ref = time()
    sim = RenderNaiveGen.RenderNaive(galaxie)
    end_ref = start_ref

    if is_iteratif
        for i in 1:nb_iterations
            t0 = time()
            RenderNaiveGen.execute(sim)
            t1 = time()
            execTime = t1 - t0
            @printf("ExecTime = %.6f sec.\n", execTime)
        end
        cpt = nb_iterations
        end_ref = time()
    elseif is_temporel
        cpt = 0
        temps = 0.0
        while temps <= temps_traitements
            t0 = time()
            cpt += 1
            RenderNaiveGen.execute(sim)
            t1 = time()
            execTime = t1 - t0
            temps += execTime
            @printf("Exécution n° %d ExecTime = %.6f sec.\n", cpt, execTime)
        end
        end_ref = time()
    end

    # === Calcul des caractéristiques ===
    total_mass = 0.0
    sum_pos_x = 0.0; sum_pos_y = 0.0; sum_pos_z = 0.0
    sum_vel_x = 0.0; sum_vel_y = 0.0; sum_vel_z = 0.0

    for i in 1:galaxie.size
        total_mass += galaxie.mass[i]
        sum_pos_x += galaxie.mass[i] * galaxie.pos_x[i]
        sum_pos_y += galaxie.mass[i] * galaxie.pos_y[i]
        sum_pos_z += galaxie.mass[i] * galaxie.pos_z[i]

        sum_vel_x += galaxie.vel_x[i]
        sum_vel_y += galaxie.vel_y[i]
        sum_vel_z += galaxie.vel_z[i]
    end

    mean_mass = total_mass / galaxie.size
    center_x = sum_pos_x / total_mass
    center_y = sum_pos_y / total_mass
    center_z = sum_pos_z / total_mass

    mean_vel_x = sum_vel_x / galaxie.size
    mean_vel_y = sum_vel_y / galaxie.size
    mean_vel_z = sum_vel_z / galaxie.size

    tmps_tot = end_ref - start_ref
    tmps_mean = cpt > 0 ? (tmps_tot / cpt) : 0.0

    println("=========================== caractéristique de la galaxie  =========================== ")
    println("Nombre de particules : ", galaxie.size)
    println(@sprintf("Masse totale         : %.6e", total_mass))
    println(@sprintf("Masse moyenne        : %.6e", mean_mass))
    println(@sprintf("Centre de masse      : (%.6e, %.6e, %.6e)", center_x, center_y, center_z))
    println(@sprintf("Vitesse moyenne      : (%.6e, %.6e, %.6e)", mean_vel_x, mean_vel_y, mean_vel_z))
    println("=========================== ============================== =========================== ")
    println("=========================== Calculs temporels  =========================== ")
    println(@sprintf("Temps moyen par itération : %.6f sec.", tmps_mean))
    println(@sprintf("Temps total pour %d itérations : %.6f sec.", cpt, tmps_tot))
    println("=========================== ============================== =========================== ")

    # Sauvegarde particules finales
    gr = RenderNaiveGen.particules(sim)
    FileTools.save_to_file(gr, "particules.out", fmt="tab")

    # Écriture CSV
    mkpath("results")
    csvpath = joinpath("results", "julia_results.csv")
    need_header = !isfile(csvpath) || filesize(csvpath) == 0
    open(csvpath, "a") do io
        if need_header
            write(io, "lang,mode,nb_particules,total_mass,mean_mass,center_x,center_y,center_z,mean_vel_x,mean_vel_y,mean_vel_z,tmps_mean,tmps_total,caracteristiques,calculs_temporels\n")
        end
        carac = @sprintf("Nombre de particules : %d; Masse totale : %.6e; Masse moyenne : %.6e; Centre de masse : (%.6e, %.6e, %.6e); Vitesse moyenne : (%.6e, %.6e, %.6e)", galaxie.size, total_mass, mean_mass, center_x, center_y, center_z, mean_vel_x, mean_vel_y, mean_vel_z)
        temp = @sprintf("Temps moyen par itération : %.6f sec.; Temps total : %.6f sec.", tmps_mean, tmps_tot)
        mode = is_iteratif ? "iteration" : "temporel"
        @printf(io, "julia,%s,%d,%.6e,%.6e,%.6e,%.6e,%.6e,%.6e,%.6e,%.6e,%.6f,%.6f,\"%s\",\"%s\"\n",
            mode, galaxie.size, total_mass, mean_mass,
            center_x, center_y, center_z,
            mean_vel_x, mean_vel_y, mean_vel_z,
            tmps_mean, tmps_tot,
            carac, temp)
    end

    return 0
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end