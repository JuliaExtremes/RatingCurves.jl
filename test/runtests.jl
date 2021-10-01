using RatingCurves
using Test

@testset "RatingCurves.jl" begin
    include("structures_test.jl")
    include("parameterestimation_test.jl")
end
