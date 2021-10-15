"""
    CompoundRatingCurve(threshold::Vector{<:Real},rc::Vector{RatingCurve})

Construct an object of type CompoundRatingCurve
"""
struct CompoundRatingCurve
    threshold::Vector{<:Real}
    component::Vector{RatingCurve}
    
    function CompoundRatingCurve(threshold::Vector{<:Real}, component::Vector{RatingCurve})
        length(threshold) == ( length(component) - 1 ) ||
            error("The number of segments does not match the number of rating curves.")
        new(threshold, component)
    end
    
end

CompoundRatingCurve(threshold::Vector{<:Int}, component::Vector{RatingCurve}) = CompoundRatingCurve(float.(threshold), component)

Base.Broadcast.broadcastable(obj::CompoundRatingCurve) = Ref(obj)

"""
    function bic(crc::CompoundRatingCurve)

BIC of the compound rating curve model.
"""
function bic(crc::CompoundRatingCurve)
   
    n₁ = length(crc.component[1].gauging)
    n₂ = length(crc.component[2].gauging)
    n = n₁ + n₂
    p = 6
    
    @assert n>6 
    
    σ̂² = RatingCurves.var(crc)
    
    return n₁*log(σ̂²[1]) + n₂*log(σ̂²[2]) + p*log(n)
    
end

"""
    cint(crc::CompoundRatingCurve; nboot::Int=100, α::Real=.05)

Compound rating curve parameter confidence intervals of level `1-α` obtained by a bootstrap sample of size `nboot`.
"""
function cint(crc::CompoundRatingCurve; nboot::Int=200, α::Real=.05)
    
    k = Vector{Float64}(undef, nboot)
    
    a₁ = Vector{Float64}(undef, nboot)
    b₁ = Vector{Float64}(undef, nboot)
    c₁ = Vector{Float64}(undef, nboot)
    
    a₂ = Vector{Float64}(undef, nboot)
    b₂ = Vector{Float64}(undef, nboot)
    c₂ = Vector{Float64}(undef, nboot)
    
    for i in 1:nboot
       
        G₁ = RatingCurves.bootstrap(crc.component[1].gauging)
        G₂ = RatingCurves.bootstrap(crc.component[2].gauging)
        crcᵢ = crcfit([G₁..., G₂...])
        
        k[i] = crcᵢ.threshold[1]
        
        a₁[i] = crcᵢ.component[1].a
        b₁[i] = crcᵢ.component[1].b
        c₁[i] = crcᵢ.component[1].c
        
        a₂[i] = crcᵢ.component[2].a
        b₂[i] = crcᵢ.component[2].b
        c₂[i] = crcᵢ.component[2].c
        
    end
    
    M = hcat(
            quantile(k, [α/2, 1-α/2]),
            quantile(a₁, [α/2, 1-α/2]),
            quantile(b₁, [α/2, 1-α/2]),
            quantile(c₁, [α/2, 1-α/2]),
            quantile(a₂, [α/2, 1-α/2]),
            quantile(b₂, [α/2, 1-α/2]),
            quantile(c₂, [α/2, 1-α/2])
            )
    
    return M
    
end

"""
    discharge(crc::RatingCurve, h::Real)

Compute the estimated discharge at level `h` with the compound rating curve `crc`.
"""
function discharge(crc::CompoundRatingCurve, h::Real)
    
    y = logdischarge(crc, h)
    
    return exp(y)
    
end

"""
    level(crc::RatingCurve, q::Real)

Compute the level corresponding the the discharge `q` and the compound rating curve `crc`.
"""
function level(crc::CompoundRatingCurve, q::Real)
    
    @assert q>0
    
    threshold = vcat(crc.threshold, Inf)
    component = crc.component
    
    i = 1
    h = level(component[i], q)
    
    while(h > threshold[i])
        i +=1
        h = level(component[i], q)
    end
    
    return h
    
end

"""
    logdischarge(crc::RatingCurve, h::Real)

Compute the estimated log discharge at level `h` with the compound rating curve `crc`.
"""
function logdischarge(crc::CompoundRatingCurve, h::Real)
    
    threshold = vcat(crc.threshold, Inf)
    
    ind = findfirst(h .< threshold)
    
    y = logdischarge(crc.component[ind], h)
    
    return y
    
end

"""
    pint(crc::CompoundRatingCurve, level::Real, α::Real=0.05, rtol::Real=.05)

`1-α` confidence interval of the estimated discharge at level `h` with the compound rating curve `crc`.

### Details

`rtol` represents the relative uncertainty of the dishcarge so that the true discharge is included in the interval `q ± 1.96*rtol` 95% of the time
"""
function pint(crc::CompoundRatingCurve, level::Real, α::Real=0.05, rtol::Real=.05)
    
    res = pintlog(crc, level, α, rtol)
    
    return exp.(res)
end



"""
    pintlog(crc::CompoundRatingCurve, level::Real, α::Real=0.05, rtol::Real=.05)

`1-α` confidence interval of the estimated log discharge at level `h` with the compound rating curve `crc`.

### Details

`rtol` represents the relative uncertainty of the dishcarge so that the true discharge is included in the interval `q ± 1.96*rtol` 95% of the time
"""
function pintlog(crc::CompoundRatingCurve, level::Real, α::Real=0.05, rtol::Real=.05)
    
    threshold = vcat(crc.threshold, Inf)
    
    ind = findfirst(level .< threshold)
    
    rc = crc.component[ind]
    
    return pintlog(rc, level, α, rtol)
    
end

"""
    Base.show(io::IO, obj::EVA)
Override of the show function for the objects of type RatingCurve.
"""
function Base.show(io::IO, obj::CompoundRatingCurve)

    showCompoundRatingCurve(io, obj)

end

function showCompoundRatingCurve(io::IO, obj::CompoundRatingCurve)

    threshold = [0, obj.threshold..., Inf]
    println(io, "CompoundRatingCurve")
    for i in 1:length(obj.component)
        println(io, "")
        println(io, "   for ",threshold[i]," ≤ h < ",threshold[i+1])
        showRatingCurve(io, obj.component[i],"      ")
    end
end

"""
    sse(rc::RatingCurve)

Compute the sum of the squares of residuals between the compound curve and the gauging in the log space.

### Details
A value of the sum of squares is given for each CompoundRatingCurve component.
"""
function sse(crc::CompoundRatingCurve)
    
    SSE = Float64[]
    
    for rc in crc.component
        push!(SSE, sse(rc)[])
    end
    
    return SSE

end

"""
    var(crc::CompoundRatingCurve)

Estimate the variance of the errors in the log space.
"""
function var(crc::CompoundRatingCurve)
   
    σ̂² = Float64[]
    
    for rc in crc.component
        push!(σ̂², RatingCurves.var(rc)[])
    end
    
    return σ̂²
    
end