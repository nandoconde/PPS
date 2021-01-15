module Tuning

using LinearAlgebra
export tune_design

function tune_design(n::Integer, H::Tuple{Real,Real}, εᵣ::Real, lₛ::Real)
    r = range(0.4,1.3,length=15)
    cost_f = Tuning.coste(n,H,εᵣ,lₛ)
    coste = mapreduce((x) -> cost_f(x.c,x.la),min,((c=(c1,c2,c3),la=(l1,l2)) for c1=copy(r),c2=copy(r),c3=copy(r),l1=copy(r),l2=copy(r)))
end

"""
    cost_synthesis(c::Tuple{Real,Real,Real}, lₐ::Tuple{Real,Real}, n::Integer, H::Tuple{Real,Real}, εᵣ::Real, lₛ::Real)

Compute the cost function of given synthesis for optimization, compared to ideal periodic synthesis.

# Arguments
- `c::Tuple{Real,Real,Real}`: tuple of H scale factors (first, middle and last)
- `lₐ::Tuple{Real,Real}`: tuple of air length scale factors (first N-2 and last)
- `n::Integer`: number of PPS layers
- `H::Tuple{Real,Real}`: tuple of normalised parallel admittances
- `εᵣ::Real`: relative permittivity of dielectric
- `lₛ::Real`: depth of dielectric as factor of λ/4
"""
function cost_synthesis(c::Tuple{Real,Real,Real}, lₐ::Tuple{Real,Real}, n::Integer, H::Tuple{Real,Real}, εᵣ::Real, lₛ::Real)
    # Constants
    μ₀ = 1.25663706212e-6
    ε₀ = 8.8541878128e-12
    Z₀ = √(μ₀/ε₀)
    Zₚ = √(μ₀/(εᵣ*ε₀))
    (H1,H2) = H
    (c1,c2,c3) = c
    (L1,L3) = lₐ

    # Ideal
    Tᵢ = Tₚ(H1)*Taire(1)
    for i in 1:(n-2)
        Tᵢ = Tᵢ*Tₚ(H2)*Taire(1)
    end
    Tᵢ = Tᵢ*Tₚ(H1)

    # Real device
    Tᵣ = Tₚ(H1;c=c1)*Tdiel(εᵣ,lₛ)*Taire(L1)*Tₚ(H2;c=c2)*Tdiel(εᵣ,lₛ)
    for i in 1:(n-3)
        Tᵣ = Taire(L1)*Tᵣ*Tₚ(H2;c=c2)*Tdiel(εᵣ,lₛ)
    end
    Tᵣ = Tᵣ*Taire(L3)*Tdiel(εᵣ,lₛ)*Tₚ(H1;c=c3)
    
    # Cost
    cost = LinearAlgebra.norm(Tᵢ - Tᵣ, 2)
    if abs(cost-0.3051346554380386)<1e-5
        print(c)
        print(lₐ)
    end
    return cost
    
end
    
function coste(n::Int, H::Tuple{Real,Real}, εᵣ::Real, lₛ::Real)
    return (c::Tuple{Real,Real,Real}, lₐ::Tuple{Real,Real}) -> cost_synthesis(c, lₐ, n, H, εᵣ, lₛ)
end

function Tₚ(H::Real;c::Real=1)
    a = 1 / (c*H)
    tₐ = (1 / 2a)im
    [1 tₐ 0 tₐ;tₐ 1 tₐ 0;0 -tₐ 1 -tₐ;-tₐ 0 -tₐ 1]
end

function Taire(l::Real)
    air = exp(-im * π / 2 * l)
    return [air 0 0 0;0 air 0 0;0 0 conj(air) 0;0 0 0 conj(air)]
end

function Tdiel(εᵣ::Real,l::Real)
    # Constants
    μ₀ = 1.25663706212e-6
    ε₀ = 8.8541878128e-12
    Z₀ = √(μ₀/ε₀)
    Zₚ = √(μ₀/(εᵣ*ε₀))

    s₁₁ₑ = (Zₚ - im * Z₀ * tan((π / 2) * l * √(εᵣ) / 2)) / (Zₚ + im * Z₀ * tan((π / 2) * l * √(εᵣ) / 2))
    s₁₁ₒ = (im * Zₚ * tan((π / 2) * l * √(εᵣ) / 2) - Z₀) / (im * Zₚ * tan((π / 2) * l * √(εᵣ) / 2) + Z₀)
    s₁₁ = (s₁₁ₑ + s₁₁ₒ) / 2
    s₁₃ = (s₁₁ₑ - s₁₁ₒ) / 2
    Sₛ = [s₁₁ 0 s₁₃ 0;0 s₁₁ 0 s₁₃;s₁₃ 0 s₁₁ 0;0 s₁₃ 0 s₁₁]
    Tₛ = Array{ComplexF64,2}(undef, 4, 4)
    Tₛ[[1,2],[1,2]] = Sₛ[[1,2],[3,4]] - Sₛ[[1,2],[1,2]] * inv(Sₛ[[3,4],[1,2]]) * Sₛ[[3,4],[3,4]]
    Tₛ[[1,2],[3,4]] = Sₛ[[1,2],[1,2]] * inv(Sₛ[[3,4],[1,2]])
    Tₛ[[3,4],[1,2]] = -inv(Sₛ[[3,4],[1,2]]) * Sₛ[[3,4],[3,4]]
    Tₛ[[3,4],[3,4]] = inv(Sₛ[[3,4],[1,2]])
    return Tₛ
end


end