module PPS_dev
# This module simulates what in the future will be in a Pluto.jl notebook
# All code is within module to avoid global scope

# Include (in any way) the PPS tools
include("src/PPS.jl")
using .PPS

# -----------------------------------------------
#                   SETUP
# -----------------------------------------------
# Create analysis parameters
workpath = raw"temp\1. L-bend (build)"
symmetry = "single"
topology = "trellis"
foster_form = "Y"
unitcell_descriptor = UnitCell(workpath, symmetry, topology, foster_form)
# Setup workspace using CST results
(freqs,Zref,S,parameters) = cell_setup(unitcell_descriptor)


end