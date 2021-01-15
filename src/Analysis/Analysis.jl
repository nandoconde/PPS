module Analysis

# Load definitions module
include("../Definitions.jl")
using .Definitions
# Load CST file reader
include("readCSTfiles.jl")

# Export main analysis function
export cell_analysis



function cell_analysis(cell::UnitCell)
    # Read from CST
    readCST(cell.path)

    # Filter frequencies (this will be different for oblique incidence?)


    # Remove dielectric (unnecessary, because vacuum cells can be analysed and then extracted)


    # Extract equivalent circuit


    # Error metrics


    
end
    
end