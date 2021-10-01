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