using Documenter, RatingCurves

CI = get(ENV, "CI", nothing) == "true"

makedocs(sitename = "RatingCurves.jl",
    format = Documenter.HTML(
    prettyurls = CI,
    ),
    pages = [
       "index.md",
       "contributing.md",
       "functions.md"
       ]

)

deploydocs(
    repo = "github.com/JuliaExtremes/RatingCurves.jl.git",
)