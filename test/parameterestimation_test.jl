@testset "rcfit with given h and q" begin
    h = [2,3,4]
    q = [3,12,27]
    
    rc = rcfit(h,q)

    @test rc.gauging == Gauging.(h,q)
    @test rc.a ≈ 3.0
    @test rc.b ≈ 1.0
    @test rc.c ≈ 2.0

end