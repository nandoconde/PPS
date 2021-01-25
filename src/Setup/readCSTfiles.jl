using DelimitedFiles

function getCSTfolder(CST_root::AbstractString)
    for s in match.(r".*\.cst",readdir(CST_root;join=true))
        isnothing(s) && continue
        nombres = rsplit(s.match,'.';limit=2)
        return String(nombres[1])
    end
end

function getfrequencies(path_freqs::AbstractString)
    freqs = open(path_freqs;read=true) do io
        A = readdlm(io,Float64;skipstart=3)
        A[:,1].*1e9
    end
    return freqs
end

function getimpedances(path_impedances::AbstractString)
    impedances = open(path_impedances;read=true) do io
        A = readdlm(io,Float64)
        A[:,2]
    end
    return impedances
end

function getimpedances(paths_impedances::AbstractArray{<:AbstractString,1},F::Int64)
    Zref = Array{Float64,2}(undef,4,F)
    for i = 1:4
        Zref[i,:] = getimpedances(paths_impedances[i])
    end
    return Zref
end

function getparameters(path_parameters::AbstractString)
    dictionary = open(path_parameters;read=true) do io
        D = Dict{String,Float64}()
        for line in eachline(io)
            l = split(line,"=")
            key = String(l[1])
            value = isnothing(tryparse(Float64,l[2])) ? D[l[2]] : parse(Float64,l[2])
            D[key] = value
        end
        D
    end
    return dictionary
end


function getscattering(path_scattering::AbstractString)
    S = open(path_scattering;read=true) do io
        A = readdlm(io,Float64)
        (A[:,2] + 1im*A[:,3])
    end
    return S
end

function getscattering(paths_scattering::AbstractArray{<:AbstractString,2},F::Int64)
    S = Array{ComplexF64,3}(undef,4,4,F)
    for CI in CartesianIndices((4,4))
        S[CI,:] = getscattering(paths_scattering[CI])
    end
    return S
end

"""
    readCST(dir_root::String)

Read CST results and return them.

## Results

The following results are returned in a tuple

- `freqs::Array{Float64,1}`: simulation frequencies.
  - **Units:** Hz
  - **Size:** F×1
  - **Explanation:**
    >
    >  1. Frequencies are always real
    >  2. Julia uses column-major order
    >
- `Zref::Array{Float64,2}`: port reference impedances.
  - **Units:** Ω
  - **Size:** 4×F×R
  - **Explanation:**
    >
    >  1. Four ports usually are accessed simultaneously
    >  2. For fundamental modes, it is constant in frequency.
    >     However, this changes for higher-order and might be implemented later.
    >  3. Furthermore, CST always exports it as an array
    >  4. It is always real (when it is not below cutoff)
    >
- `S_Params::Array{ComplexF64,4}`: S-parameters from FEM simulation referenced to `Zref`
  - **Units:** *none*
  - **Size:** 4×4×F×R
  - **Explanation:**
    >
    >  1. **S** matrices are generally complex
    >  2. 4×4 matrices are accessed usually simulataneously.
    >     This extends to 4×4×F blocks.
    >
- `parameters::Array{Dict{String,Float64},1},` parameters present at CST execution
  - **Size:** R×1
  - **Explanation:**
    >
    >  1. Dictionary of parameters for each execution
    >  2. A reverse dictionary, matching specific parameters to executions was not needed
    >
"""
function readCST(dir_root::String)
    # Filenames
    filenames_Zref = ["ZRef Zmax(1).txt","ZRef Zmax(2).txt",
                  "ZRef Zmin(1).txt","ZRef Zmin(2).txt"]
    filenames_S = Array{String,2}(undef,4,4)
    filenames_S[1,1:2] = ["SZmax(1),Zmax(1).txt","SZmax(1),Zmax(2).txt"]
    filenames_S[1,3:4] = ["SZmax(1),Zmin(1).txt","SZmax(1),Zmin(2).txt"]
    filenames_S[2,1:2] = ["SZmax(2),Zmax(1).txt","SZmax(2),Zmax(2).txt"]
    filenames_S[2,3:4] = ["SZmax(2),Zmin(1).txt","SZmax(2),Zmin(2).txt"]
    filenames_S[3,1:2] = ["SZmin(1),Zmax(1).txt","SZmin(1),Zmax(2).txt"]
    filenames_S[3,3:4] = ["SZmin(1),Zmin(1).txt","SZmin(1),Zmin(2).txt"]
    filenames_S[4,1:2] = ["SZmin(2),Zmax(1).txt","SZmin(2),Zmax(2).txt"]
    filenames_S[4,3:4] = ["SZmin(2),Zmin(1).txt","SZmin(2),Zmin(2).txt"]

    # Get folders and files
    dir_CST = getCSTfolder(dir_root)
    dir_results = joinpath(dir_CST,"Export_Parametric")
    cell_results = readdir(dir_results;join=true)
    R = length(cell_results)
    file_test_freqs = joinpath(dir_CST,"Export","1D","Frecuencias.txt")

    # Read frequencies
    freqs = getfrequencies(file_test_freqs)
    F = length(freqs)

    # Preallocate arrays
    parameters = Array{Dict{String,Float64},1}(undef,R)
    S = Array{ComplexF64,4}(undef,4,4,F,R)
    Zref = Array{Float64,3}(undef,4,F,R)

    # Iterate through folders to fill results
    for r = 1:R
        # # Set up iteration
        # # Parameters
        file_parameters = joinpath(cell_results[r],"Parameters.txt")
        parameters[r] = getparameters(file_parameters)

        # # S-Matrix
        files_S = joinpath.(cell_results[r],"S-Parameters",filenames_S)
        S[:,:,:,r] = getscattering(files_S,F)

        # # Reference impedances
        files_Zref = joinpath.(cell_results[r],"Reference Impedance",filenames_Zref)
        Zref[:,:,r] = getimpedances(files_Zref,F)
    end

    # Return results
    return (freqs,Zref,S,parameters)

end
