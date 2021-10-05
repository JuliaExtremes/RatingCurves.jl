using RatingCurves
using Random, Test

@testset "RatingCurves.jl" begin
    include("structures_test.jl")
    include("parameterestimation_test.jl")
end
