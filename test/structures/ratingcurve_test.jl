@testset "RatingCurve type" begin

    G = Gauging.([1,2],[3,4])
    
    # Test the construction
    rc = RatingCurve(G, 1.0, 2.0, 3.0)
    @test rc.gauging == G 
    @test rc.a ≈ 1.0 atol = sqrt(eps())
    @test rc.b ≈ 2.0 atol = sqrt(eps())
    @test rc.c ≈ 3.0 atol = sqrt(eps())
    
    # Test the promotion of parameters
    rc = RatingCurve(G, 1, 2, 3)
    @test typeof(rc.a) == Float64
    @test typeof(rc.b) == Float64
    @test typeof(rc.c) == Float64

    # Test the promotion of a paramter
    rc = RatingCurve(G, 1, 2.0, 3.0)
    @test typeof(rc.a) == Float64

end
