@testset "CompoundRatingCurve type" begin

    G₁ = Gauging.([1,2],[3,4])
    rc₁ = RatingCurve(G₁, 1, 2, 3)
    G₂ = Gauging.([5,6],[7,8])
    rc₂ = RatingCurve(G₂, 4, 5, 6)
    crc = CompoundRatingCurve([4.5], [rc₁, rc₂])

    @test crc.threshold ≈ [4.5] atol = sqrt(eps())
    @test crc.component[1] == rc₁
    @test crc.component[2] == rc₂

    # Test the promotion of the threshold
    crc = CompoundRatingCurve([4], [rc₁, rc₂])
    @test typeof(crc.threshold[]) == Float64

    # Test for the wrong number of threholds
    @test_throws ErrorException CompoundRatingCurve([4.5, 5], [rc₁, rc₂])

end

@testset "bic CompoundRatingCurve" begin
    #TODO
end

@testset "cint CompoundRatingCurve" begin
    #TODO
end

@testset "discharge with compound rating curve" begin
    rc₁ = RatingCurve(Gauging[], 1, 0, 3)
    rc₂ = RatingCurve(Gauging[], 3, 1, 2)
    crc = CompoundRatingCurve([1], [rc₁, rc₂])
    @test discharge(crc,1/2) ≈ 1/8
    @test discharge(crc,1) ≈ 0.0
    @test discharge(crc,2) ≈ 3.0
end

@testset "level with compound rating curve" begin
    rc₁ = RatingCurve(Gauging[], 1, 0, 3)
    rc₂ = RatingCurve(Gauging[], 3, 1, 2)
    crc = CompoundRatingCurve([1], [rc₁, rc₂])
    @test level(crc, 3) ≈ 2.0
    @test level(crc,1/8) ≈ 1/2
    @test level(crc,12) ≈ 3
end

@testset "logdischarge with compound rating curve" begin
    rc₁ = RatingCurve(Gauging[], 1, 0, 3)
    rc₂ = RatingCurve(Gauging[], 3, 1, 2)
    crc = CompoundRatingCurve([1], [rc₁, rc₂])
    @test logdischarge(crc,1/2) ≈ log(1/8)
    @test logdischarge(crc,2) ≈ log(3)
end

@testset "pint CompoundRatingCurve" begin
    #TODO
end

@testset "pintlog CompoundRatingCurve" begin
    #TODO
end

@testset "sse of a CompoundRatingCruver" begin
    G = Gauging.([1/4, 1/3, 1/2, 2,3,4],[1/32, 2/27, 1/4, 8, 18, 32])
    crc = crcfit(G)
    
    SSE = RatingCurves.sse(crc)
    
    @test (SSE[1]) ≈ 0.0 atol=sqrt(eps())
    @test SSE[2] ≈ 0.0 atol=sqrt(eps())
    
end

@testset "var of RatingCurve" begin
    param = RatingCurve(Gauging[], 2, 0, 3)
    
    h = range(1, stop=2, length=10)

    Random.seed!(MersenneTwister(1234))
    y = logdischarge.(param, h) + .01*randn(10)

    q = exp.(y)

    G = Gauging.(h, q)
    
    rc = RatingCurve(G, 2,0,3)
    
    crc = CompoundRatingCurve([1], [rc, rc])
    
    σ̂² = RatingCurves.var(crc)
    
    @test σ̂²[1] ≈ 0.00013060186244030195 atol=sqrt(eps())
    @test σ̂²[2] ≈ 0.00013060186244030195 atol=sqrt(eps())
    
end