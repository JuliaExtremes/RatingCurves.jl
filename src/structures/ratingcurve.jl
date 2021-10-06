
"""
    RatingCurve(G::Vector{Gauging}, a::Real, b::Real, c::Real)

Construct an object of type RatingCurve
"""
struct RatingCurve
    gauging::Vector{Gauging}
    a::Real
    b::Real
    c::Real
    RatingCurve(gauging::Vector{Gauging}, a::T,b::T,c::T) where {T<:Real} = new(gauging,a,b,c)
end

RatingCurve(gauging::Vector{Gauging}, a::Real, b::Real, c::Real) = RatingCurve(gauging, promote(a, b, c)...)
RatingCurve(gauging::Vector{Gauging}, a::Integer, b::Integer, c::Integer) = RatingCurve(gauging, float(a), float(b), float(c))
RatingCurve() = RatingCurve(Gauging[], 0.0, 0.0, 0.0)

Base.Broadcast.broadcastable(obj::RatingCurve) = Ref(obj)


"""
    cint(rc::RatingCurve; nboot::Int=1000, α::Real=.05)

Rating curve parameter confidence intervals of level `1-α` obtained by a bootstrap sample of size `nboot`.
"""
function cint(rc::RatingCurve; nboot::Int=1000, α::Real=.05)
    
    a = Vector{Float64}(undef, nboot)
    b = Vector{Float64}(undef, nboot)
    c = Vector{Float64}(undef, nboot)
    
    for i in 1:nboot
       
        Gᵢ = RatingCurves.bootstrap(rc.gauging)
        rcᵢ = rcfit(Gᵢ)
        
        a[i] = rcᵢ.a
        b[i] = rcᵢ.b
        c[i] = rcᵢ.c
        
    end
    
    M = hcat(
            quantile(a, [α/2, 1-α/2]),
            quantile(b, [α/2, 1-α/2]),
            quantile(c, [α/2, 1-α/2])
            )
    
    return M
    
end

"""
    discharge(rc::RatingCurve, h::Real)

Compute the estimated discharge at level `h` with the rating curve `rc`.
"""
function discharge(rc::RatingCurve, h::Real)
    
    y = logdischarge(rc, h)
    
    return exp(y)
    
end

"""
    level(rc::RatingCurve, q::Real)

Estimate the level corresponding to the discharge `q` with the rating curve `rc`.
"""
function level(rc::RatingCurve, q::Real)
    
    @assert q>0
    
    h = rc.b + (q/rc.a)^(1/rc.c)
    
    return h
    
end

"""
    logdischarge(rc::RatingCurve, h::Real)

Compute the log of the estimated discharge at level `h` with the rating curve `rc`.
"""
function logdischarge(rc::RatingCurve, h::Real)
    
    if (h>rc.b) & (rc.a>0) 
        y = log(rc.a) + rc.c*log(h-rc.b)
    else
        y = -Inf
    end
    
    return y
    
end

"""
    pint(rc::RatingCurve, level::Real, α::Real=0.05, rtol::Real=.05)

`1-α` Confidence interval of the estimated discharge at level `h` with the rating curve `rc`.

### Details

`rtol` represents the relative uncertainty of the dishcarge so that the true discharge is included in the interval `q ± 1.96*rtol` 95% of the time.
"""
function pint(rc::RatingCurve, level::Real, α::Real=0.05, rtol::Real=.05)
    
    res = pintlog(rc, level, α, rtol)
    
    return exp.(res)
    
end

"""
    pintlog(rc::RatingCurve, level::Real, α::Real=0.05, rtol::Real=.05)

`1-α` confidence interval of the estimated log discharge at level `h` with the rating curve `rc`.

### Details

`rtol` represents the relative uncertainty of the dishcarge so that the true discharge is included in the interval `q ± 1.96*rtol` 95% of the time
"""
function pintlog(rc::RatingCurve, level::Real, α::Real=0.05, rtol::Real=.05)
    
    @assert 0<α<1
    @assert 0<rtol<1
    @assert level>rc.b
    
    # Rating curve error in log space
    σ̂² = RatingCurves.var(rc)[]
    
    # Relative discharge error in log space
    τ² = (rtol/1.96)^2
    
    pd = Normal(logdischarge(rc, level), sqrt(σ̂² + τ²))
    
    lower = quantile(pd, α/2)
    upper = quantile(pd, 1-α/2)
    
    return [lower, upper]
    
end


"""
    Base.show(io::IO, obj::EVA)
Override of the show function for the objects of type RatingCurve.
"""
function Base.show(io::IO, obj::RatingCurve)

    showRatingCurve(io, obj)

end

function showRatingCurve(io::IO, obj::RatingCurve, prefix::String = "")

    println(io, prefix, "RatingCurve")
    println(io, prefix ,"   ", "data: ", typeof(obj.gauging), "[", length(obj.gauging), "]")
    println(io, prefix, "   ", "Parameters:")
    println(io, prefix, "      ", "a = ", obj.a)
    println(io, prefix, "      ", "b = ", obj.b)
    println(io, prefix, "      ", "c = ", obj.c)

end

"""
    sse(rc::RatingCurve)

Compute the sum of the squares of residuals between the curve and the gauging in the log space.
"""
function sse(rc::RatingCurve)
    
    h = level.(rc.gauging)
    q = discharge.(rc.gauging)
    
    y = log.(q)
    
    ŷ = logdischarge.(rc, h)
    
    SSE = sum((y - ŷ).^2)
    
    return [SSE]

end

"""
    var(rc::RatingCurve)

Estimate the variance of the errors in the log space.
"""
function var(rc::RatingCurve)
   
    n = length(rc.gauging)
    p = 3
    
    SSE = RatingCurves.sse(rc)
    
    σ̂² = SSE./(n-p)
    
    return σ̂²
    
end
