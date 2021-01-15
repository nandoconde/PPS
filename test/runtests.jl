# using PPS
pwd()
include("..\\PPS.jl")
using Test

uc = UnitCell(raw"C:\Users\ferna\Desktop\Trabajo\1. L-bend\1. L-bend (build)",Symmetry.diagonal,"T","Y")
cell_analysis(uc)
# @testset "PPS.jl" begin
#     # Write your tests here.
# end
