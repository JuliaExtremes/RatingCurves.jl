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

@testset "cint RatingCurve" begin
    #TODO
end

@testset "discharge" begin
    rc = RatingCurve(Gauging[], 3, 1, 2)
    @test discharge(rc, 3) ≈ 12.0
end

@testset "level" begin
    rc = RatingCurve(Gauging[], 3, 1, 2)
    @test level(rc, 12) ≈ 3.0
end

@testset "logdischarge" begin
    rc = RatingCurve(Gauging[], 3, 1, 2)
    @test logdischarge(rc, 3) ≈ log(12)
end

@testset "sse of a RatingCurve" begin
    G = Gauging.([2,3,4],[8, 18, 32])
    rc = rcfit(G)
    
    SSE = RatingCurves.sse(rc)[]
        
    @test SSE ≈ 0.0 atol=sqrt(eps())
    
end

@testset "var of RatingCurve" begin
    param = RatingCurve(Gauging[], 2, 0, 3)
    
    h = range(1, stop=2, length=10)

    Random.seed!(1234)
    y = logdischarge.(param, h) + .01*randn(10)

    q = exp.(y)

    G = Gauging.(h, q)
    
    rc = RatingCurve(G, 2,0,3)
    
    σ̂² = RatingCurves.var(rc)[]
    
    @test σ̂² ≈ 0.00013060186244030195 atol=sqrt(eps())
    
end