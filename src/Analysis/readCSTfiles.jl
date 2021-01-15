using DelimitedFiles, StaticArrays

function getCSTfolder(CST_root::String)
    for s in match.(r".*\.cst",readdir(CST_root;join=true))
        isnothing(s) && continue
        nombres = rsplit(s.match,'.';limit=2)
        return nombres[1]
    end
end

function getfrequencies(path_freqs::String)
    freqs = open(path_freqs;read=true) do io
        A = readdlm(io,Float64;skipstart=3)
        A[:,1].*1e9
    end
    return freqs
end

function getimpedances(path_impedances::String)
    impedances = open(path_impedances;read=true) do io
        A = readdlm(io,Float64)
        A[:,2]
    end
    return impedances
end

function readCST(dir_root::String)
    
    # Filenames
    files_Zref = ["ZRef Zmax(1).txt",
    "ZRef Zmax(2).txt",
    "ZRef Zmin(1).txt",
    "ZRef Zmin(2).txt"]
    files_S_params = ["SZmax(1),Zmax(1).txt",
    "SZmax(2),Zmax(2).txt",
    "SZmax(1),Zmax(2).txt"]

    # Get folders and files
    dir_CST = getCSTfolder(dir_root)
    dir_results = joinpath(dir_CST,"Export_Parametric")
    cell_results = readdir(dir_results;join=true)
    R = length(cell_results)
    file_param_init = joinpath(cell_results[1],"Parameters.txt")
    file_test_freqs = joinpath(dir_CST,"Export","1D","Frecuencias.txt")


    # Read secondary attributes
    #   - Frequencies
    #   - Reference impedances
    #   - Parameters
    freqs = getfrequencies(file_test_freqs)
    F = length(freqs)
    
    # Preallocate big arrays
    S = Array{ComplexF64,4}(undef,4,4,F,R)
    Zref = Array{ComplexF64,4}(undef,4,F,R)

end


