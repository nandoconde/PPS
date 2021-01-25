include("readCSTfiles.jl")


function cell_setup(cell::UnitCell)
    # Read from CST
    (freqs_nofilter,Zref_nofilter,S_nofilter,parameters) = readCST(cell.path)

    # Filter frequencies (this will be different for oblique incidence?)
    # Normal incidence, square period
    fc = c₀/get(parameters[1],
            "Px",
            get(parameters[1],
                "Py",
                parameters[1]["P"]))
    freqs = freqs_nofilter[freqs_nofilter .< fc]
    F = length(freqs)
    Zref = Zref_nofilter[:,1:F,:]
    S = S_nofilter[:,:,1:F,:]

    # Remove dielectric (unnecessary, because vacuum cells can be analysed and then extracted)

    # Return results
    (freqs,Zref,S,parameters)
end