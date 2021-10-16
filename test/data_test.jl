@testset "data.jl" begin
    @testset "dataset(name)" begin
        # nonexistent file throws
        @test_throws ErrorException RatingCurves.dataset("nonexistant")

        # 50408 loading
        df = RatingCurves.dataset("50408")
        @test size(df, 1) == 194
        @test size(df, 2) == 3
    end

end