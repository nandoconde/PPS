# CONSTANTS
"Speed of light in vacuum (m/s)"
const c₀ = 299792458
"Electric permittivity of vacuum (F/m)"
const ε₀ = 8.8541878128e-12;
"Magnetic permeability of vacuum (H/m)"
const μ₀ = 1.25663706212e-6;
"Intrinsic impedance of free space (Ω)"
const η₀ = √(μ₀/ε₀)


# COMPOSITE TYPES
struct UnitCell
    path::String
    symmetry::String # (Symbol # :none, :diagonal, :xy) or String?
    topology::String # or Valued parametric type NPortCircuit (N=2)
    form::String # or create a whole circuit in topology which indicates
end