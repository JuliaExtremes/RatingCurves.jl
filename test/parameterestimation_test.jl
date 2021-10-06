
@testset "crcfit with given h and q" begin
    
    h = [1/4, 1/3, 1/2, 2,3,4]
    q = [1/32, 2/27, 1/4, 8, 18, 32]
    
    crc = crcfit(h,q)
    
    rc₁ = crc.component[1]
    rc₂ = crc.component[2]
    
    @test crc.threshold[] ≈ 1.0
    
    @test rc₁.a ≈ 2.0
    @test rc₁.b ≈ 0.0 atol=1e-8
    @test rc₁.c ≈ 3.0
    
    @test rc₂.a ≈ 2.0
    @test rc₂.b ≈ 0.0 atol=1e-8
    @test rc₂.c ≈ 2.0
end

@testset "rcfit with given h and q" begin
    h = [2,3,4]
    q = [3,12,27]
    
    rc = rcfit(h,q)

    @test rc.gauging == Gauging.(h,q)
    @test rc.a ≈ 3.0
    @test rc.b ≈ 1.0
    @test rc.c ≈ 2.0

end