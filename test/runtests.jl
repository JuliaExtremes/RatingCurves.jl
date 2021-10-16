using RatingCurves
using Random, Test

@testset "RatingCurves.jl" begin
    include("data_test.jl")
    include("structures_test.jl")
    include("parameterestimation_test.jl")
end
