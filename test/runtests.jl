# Setup test environment
using Test, LinearAlgebra
include("../src/PPS.jl")
using .PPS


#uc = UnitCell(raw"C:\Users\ferna\Desktop\Trabajo\1. L-bend\1. L-bend (build)","diagonal","T","Y")
#cell_analysis(uc)
@testset "PPS.jl" begin
    @testset "Definitions.jl" begin
        uc = UnitCell("a","b","c","d")
        @test PPS.c₀ == 299792458
        @test PPS.ε₀ == 8.8541878128e-12; 
        @test PPS.μ₀ == 1.25663706212e-6;
        @test PPS.η₀ == √(PPS.μ₀/PPS.ε₀)
        @test uc.path == "a"
        @test uc.symmetry == "b"
        @test uc.topology == "c"
        @test uc.form == "d"
    end

    @testset "circuitmatrices.jl" begin
        N = 2*round(Int,10*rand())
        F = Int(rand(UInt8))
        S = rand(ComplexF64,N,N,F)
        Zref1 = 100*rand(Float64,N,F)
        Zref2 = 100*rand(Float64,N,F)
        @test isapprox(norm(S2S(S2S(S,Zref1,Zref2),Zref2,Zref1)-S,2), 0)
        @test isapprox(norm(Z2S(S2Z(S,Zref1),Zref1)-S,2), 0)
        @test isapprox(norm(T2S(S2T(S))-S,2), 0)
    end

end
