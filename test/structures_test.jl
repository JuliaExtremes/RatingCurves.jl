@testset "structures.jl" begin
    include(joinpath("structures", "gauging_test.jl"))
    include(joinpath("structures", "ratingcurve_test.jl"))
    include(joinpath("structures", "compoundratingcurve_test.jl"))
end