# Example

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
- `dict_p2e::`
