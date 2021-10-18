
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
    function bic(rc::RatingCurve)

BIC of the rating curve model.
"""
function bic(rc::RatingCurve)
   
    n = length(rc.gauging)
    p = 3
    
    @assert n>3 
    
    σ̂² = RatingCurves.var(rc)
    
    return n*log(σ̂²[]) + p*log(n)
    
end

"""
    cint(rc::RatingCurve; nboot::Int=1000, α::Real=.05)

Rating curve parameter confidence intervals of level `1-α` obtained by a bootstrap sample of size `nboot`.
"""
function cint(rc::RatingCurve; nboot::Int=100, α::Real=.05)
    
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

@doc raw"""
    pint(rc::RatingCurve, level::Real, α::Real=0.05, rtol::Real=.05)

`1-α` confidence interval of the estimated discharge at level `h` with the rating curve `rc`.

See also [`pintlog`](@ref)e

## Details

Estimate the `1-α` confidence interval of the estimated discharge corresponding to the rating curve `rc`at level `h` 
with the relative error of the discharge measurement `rtol`.

### Measurement error

The discharge measurement uncertainty is assumed to be Gaussian. The relative error `rtol` is assumed to be ``1.96 \, τ`` where
``τ^2`` is the variance of the Gaussian measurement error. Therefore, ``τ = \operatorname{rtol}/ 1.96``. 

### Residual error

The estimation error ``σ²`` corresponding to the point on the rating curve is estimated with the sum of squared residuals in the log space. 
Let ``qᵢ`` be the observed discharge and ``q̂ᵢ`` be the corresponding discharge estimation. For the ``n>3`` gaugings, the 
sum of squared residuals is defined as:

``\operatorname{SSE} = \sum_{i=1}^n ( \log qᵢ - \log q̂ᵢ)^2.``

The variance estimation of the log residuals are therefore:

``σ̂² = \frac{1}{n-3} \operatorname{SSE}.``

### Log discharge prediction error

The log prediction variance is assumed to be the sum of the estimation variance and the discharge measurement variance in the log space.
It is then assumed that the prediction error in the log space is Gaussian in order to compute the confidence interval bounds.

### Discharge prediction error

The confidence interval bounds in the original space are given by the exponential of the bounds in the log space.

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
    
    # Rating curve variance in the log space
    σ̂² = RatingCurves.var(rc)[]
    
    # Relative discharge variance in the log space
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
