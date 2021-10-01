"""
    Gauging(level::Real, discharge::Real)

Construct an object of type Gauging
"""
struct Gauging
    level::Real
    discharge::Real
    Gauging(level::T,discharge::T) where {T<:Real} = new(level,discharge)
end

Gauging(level::Real, discharge::Real) = Gauging(promote(level, discharge)...)
Gauging(level::Integer, discharge::Integer,) = Gauging(float(level), float(discharge))
Gauging() = Gauging(0.0, 0.0)

Base.Broadcast.broadcastable(obj::Gauging) = Ref(obj)

"""
    discharge(G::Gauging)

Return the discharge of gauging `G`
"""
function discharge(G::Gauging)
    return G.discharge
end

"""
    Compute the rough initial values of the rating curve parameters.

### Details
These are rough estimates obtained by setting `c = 3/2`, `b = .9*min(h)`. The parameter `a` is computed with the median level. 
"""
function getinitialvalues(G::Vector{Gauging})
   
    h = level.(G)
    q = discharge.(G)
    
    c₀ = 1.5
    b₀ = .9*minimum(h)
    
    n = length(h)
    p = sortperm(h)
    
    index = p[floor(Int64, n/2)]

    a₀ = q[index] / (h[index] - b₀)^c₀
    
    rc = RatingCurve(G, a₀, b₀, c₀)
    
    return rc
    
end

"""
    level(G::Gauging)

Return the level of gauging `G`
"""
function level(G::Gauging)
    return G.level
end