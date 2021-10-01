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

    # Test the broadcast
    G = Gauging.([1,2],[3,4])
    @test G[2].level ≈ 2
    @test G[2].discharge ≈ 4

end

@testset "Gauging methods" begin

    # Test `level()`for a single gauging
    G = Gauging(0.0,1.0)
    @test level(G) ≈ 0.0
    
    # Test the broadcasting of `level()`
    G = Gauging.([0.0,1.0],[2.0,3.0])
    @test level.(G) ≈ [0.0, 1.0]

    # Test `discharge()`for a single gauging
    G = Gauging(0.0,1.0)
    @test discharge(G) ≈ 1.0
    
    # Test the broadcasting of `discharge()`
    G = Gauging.([0.0,1.0],[2.0,3.0])
    @test discharge.(G) ≈ [2.0, 3.0]

end

@testset "getinitialvalues" begin

    G = Gauging.([1,2,3], [4,5,6])
    rc = RatingCurves.getinitialvalues(G)

    @test rc.a ≈ 126.4911 atol = 1e-4
    @test rc.b ≈ .9
    @test rc.c ≈ 3/2

end

@testset "rcfit with given b" begin
    G = Gauging.([2,3,4],[3,12,27])
    rc = rcfit(G, 1)
    @test rc.a ≈ 3.0
    @test rc.b ≈ 1.0
    @test rc.c ≈ 2.0
end

@testset "rcfit" begin
    G = Gauging.([2,3,4],[3,12,27])
    rc = rcfit(G)
    @test rc.a ≈ 3.0
    @test rc.b ≈ 1.0
    @test rc.c ≈ 2.0
end

@testset "rcfit with given b s.t. constraint" begin
    G = Gauging.([2,3,4],[3,12,27])
    rc = rcfit(G, 1, [5, 48])
    @test rc.a ≈ 3.0
    @test rc.b ≈ 1.0
    @test rc.c ≈ 2.0
end

@testset "rcfit s.t. constraint" begin
    G = Gauging.([2,3,4],[3,12,27])
    rc = rcfit(G, [5, 48])
    @test rc.a ≈ 3.0
    @test rc.b ≈ 1.0
    @test rc.c ≈ 2.0
end

