using Documenter
using PPS

makedocs(
    sitename = "PPS",
    format = Documenter.HTML(),
    modules = [PPS]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
