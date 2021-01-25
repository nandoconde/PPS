"""
    function foster(K::Array{Float64,1},ωₚ::Array{Float64,1},ω::Array{Float64,1};k₀::Float64=0.0,k∞::Float64=0.0)

Evaluate Foster form of given poles and residues.

## Arguments
- `K::Array{Float64,1}`: residues around the poles.
  - **Units:** []
  - **Size:** P×1
  - **Explanation:**
    >
    >  1. WARNING: it is not doubled (as it was in MATLAB). Be consequent.
    >  2. P is the number of resonances in band.
    >
- `ωₚ::Array{Float64,1}`: poles' angular frequencies.
  - **Units:** [rad/s]
  - **Size:** P×1
  - **Explanation:**
    >
    >  1. P is the number of resonances in band.
    >
- `ω::Array{Float64,1}`: angular frequencies.
  - **Units:** [rad/s]
  - **Size:** F×1
  - **Explanation:**
    >
    >  `ω = 2πf`
    >
- `k₀::Float64` residue at origin.
  - **Units:** []
- `k∞::Float64` residue at infinity.
  - **Units:** []
"""

function foster(K::Array{Float64,1},
            ωₚ::Array{Float64,1},
            ω::Array{Float64,1};
            k₀::Float64=0.0,
            k∞::Float64=0.0)
    # Pole at origin
    F = -k₀./ω
    # Pole at infinity
    F += k∞.*ω
    # Poles at resonant frequencies
    for i in eachindex(K)
        F += (2*K[i].*ω)./(ωₚ[i]^2 .- ω.^2)
    end
end