using Documenter, RatingCurves, Cairo, Fontconfig

CI = get(ENV, "CI", nothing) == "true"

makedocs(sitename = "RatingCurves.jl",
    format = Documenter.HTML(
    prettyurls = CI,
    ),
    pages = [
       "index.md",
       "Tutorial" =>["Getting started" => "tutorial/index.md",
            "Data" => "tutorial/gauging.md",
            "Rating curve fitting" => "tutorial/rcfit.md"],
       "contributing.md",
       "functions.md"]
)

# if CI
#     deploydocs(
#     repo   = "github.com/JuliaExtremes/RatingCurves.jl.git",
#     devbranch = "dev",
#     versions = ["stable" => "v^", "v#.#"],
#     push_preview = false,
#     target = "build"
#     )
# end


deploydocs(
    repo = "github.com/JuliaExtremes/RatingCurves.jl.git",
)