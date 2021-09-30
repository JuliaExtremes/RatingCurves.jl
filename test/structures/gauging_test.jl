@testset "Gauging type" begin

    # Test the construction of the couple (level, discharge)
    G = Gauging(0.0,1.0)
    @test G.level ≈ 0.0 atol = sqrt(eps())
    @test G.discharge ≈ 1.0 atol = sqrt(eps())
    
    # Test the promotion of level and discharge
    G = Gauging(0,1)
    @test typeof(G.level) == Float64
    @test typeof(G.discharge) == Float64
    
    # Test the promotion of level
    G = Gauging(0,1.1)
    @test typeof(G.level) == Float64
    @test typeof(G.discharge) == Float64

end