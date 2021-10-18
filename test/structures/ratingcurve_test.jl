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

    # Test empty rating curve construction
    rc = RatingCurve() 
    @test rc.gauging == Gauging[]
    @test rc.a ≈ 0.0 atol = sqrt(eps())
    @test rc.b ≈ 0.0 atol = sqrt(eps())
    @test rc.c ≈ 0.0 atol = sqrt(eps())

end

@testset "bic RatingCurve" begin
    h = exp.([1/5, 1/4, 1/2, 1/2])
    q = exp.([8/5, 7/4, 5/2, 3])
    G = Gauging.(h,q)

    n = length(G)

    rc = RatingCurve(G, exp(1), 0, 3)

    res = bic(rc)

    @test res ≈ n*log(1/4) + 3*log(n) atol = sqrt(eps())
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

@testset "pint RatingCurve" begin
    #TODO
end

@testset "pintlog RatingCurve" begin
    #TODO
end

@testset "sse of a RatingCurve" begin

    h = exp.([1/5, 1/4, 1/2, 1/2]) # First three points on the curve
    q = exp.([8/5, 7/4, 5/2, 3])

    G = Gauging.(h,q)

    rc = RatingCurve(G, exp(1), 0, 3)

    SSE = RatingCurves.sse(rc)[]

    @test SSE ≈ 1/4 atol=sqrt(eps())
    
end

@testset "var of RatingCurve" begin
    h = exp.([1/5, 1/4, 1/2, 1/2]) # First three points are on the curve
    q = exp.([8/5, 7/4, 5/2, 3])

    G = Gauging.(h,q)

    rc = RatingCurve(G, exp(1), 0, 3)
    
    σ̂² = RatingCurves.var(rc)[]
    
    @test σ̂² ≈ 1/4 atol=sqrt(eps())
    
end