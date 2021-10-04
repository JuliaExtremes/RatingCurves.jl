
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