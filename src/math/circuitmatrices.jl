using LinearAlgebra
export S2S, S2Z, Z2S, S2T, T2S
function S2S(Sₐ::AbstractArray{<:Number,3},Zₐ::AbstractArray{<:Number,2},Zᵦ::AbstractArray{<:Number,2})
    Sᵦ = similar(Sₐ)
    for f in 1:size(Sₐ,3)
        Sᵦ[:,:,f] = S2S(Sₐ[:,:,f],Zₐ[:,f],Zᵦ[:,f])
    end
    return Sᵦ
end

function S2S(Sₐ::AbstractArray{<:Number,2},Zₐ::AbstractArray{<:Number,1},Zᵦ::AbstractArray{<:Number,1})
    U = UniformScaling(size(Sₐ,1))
    G = diagm(sqrt.(Zₐ./Zᵦ))
    Γ = diagm((Zᵦ-Zₐ)./(Zᵦ+Zₐ))
    return Sᵦ = G*inv(U-Sₐ)*(Sₐ-Γ)*inv(U-Sₐ*Γ)*(U-Sₐ)*inv(G)
end

function S2Z(S::AbstractArray{<:Number,3},Zref::AbstractArray{<:Number,2})
    Z = similar(S)
    for f in 1:size(S,3)
        Z[:,:,f] = S2Z(S[:,:,f],Zref[:,f])
    end
    return Z
end

function S2Z(S::AbstractArray{<:Number,2},Zref::AbstractArray{<:Number,1})
    G = diagm(Zref)
    F = diagm(1 ./ (2 .* sqrt.(real.(Zref))))
    return Z = ((F - S*F))\(S*G + G')*F
end

function Z2S(Z::AbstractArray{<:Number,3},Zref::AbstractArray{<:Number,2})
    S = similar(Z)
    for f in 1:size(Z,3)
        S[:,:,f] = Z2S(Z[:,:,f],Zref[:,f])
    end
    return S
end

function Z2S(Z::AbstractArray{<:Number,2},Zref::AbstractArray{<:Number,1})
    G = diagm(Zref)
    F = diagm(1 ./ (2 .* sqrt.(real.(Zref))))
    return S = F*(Z - G')/(Z + G)/F
end

function S2T(S::AbstractArray{<:Number,3})
    T = similar(S)
    for f in 1:size(S,3)
        T[:,:,f] = S2T(S[:,:,f])
    end
    return T
end

function S2T(S::AbstractArray{<:Number,2})
    T = similar(S)
    N2 = size(S,1)÷2
    if (size(S,1) % 2 == 1) || size(S,1) != size(S,2)
        error("Wrong matrix size") 
    end
    S₁₁ = S[1:N2,1:N2]
    S₁₂ = S[1:N2,N2+1:end]
    S₂₁ = S[N2+1:end,1:N2]
    S₂₂ = S[N2+1:end,N2+1:end]
    T[1:N2,1:N2] = S₁₂ - S₁₁/S₂₁*S₂₂
    T[1:N2,N2+1:end] = S₁₁/S₂₁
    T[N2+1:end,1:N2] = -S₂₁\S₂₂
    T[N2+1:end,N2+1:end] = inv(S₂₁)
    return T
end

function T2S(T::AbstractArray{<:Number,3})
    S = similar(T)
    for f in 1:size(T,3)
        S[:,:,f] = T2S(T[:,:,f])
    end
    return S
end

function T2S(T::AbstractArray{<:Number,2})
    S = similar(T)
    N2 = size(T,1)÷2
    if (size(T,1) % 2 == 1) || size(T,1) != size(T,2)
        error("Wrong matrix size") 
    end
    T₁₁ = T[1:N2,1:N2]
    T₁₂ = T[1:N2,N2+1:end]
    T₂₁ = T[N2+1:end,1:N2]
    T₂₂ = T[N2+1:end,N2+1:end]
    S[1:N2,1:N2] = T₁₂/T₂₂
    S[1:N2,N2+1:end] = T₁₁ - T₁₂/T₂₂*T₂₁
    S[N2+1:end,1:N2] = inv(T₂₂)
    S[N2+1:end,N2+1:end] = -T₂₂\T₂₁
    return S
end