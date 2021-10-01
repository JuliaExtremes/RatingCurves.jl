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

"""
    rcfit(G::Vector{Gauging})

Fit the rating curve to the gaugings `G`.
"""
function rcfit(G::Vector{Gauging})
    
    h = level.(G)
    q = discharge.(G)
    
    rc₀ = RatingCurves.getinitialvalues(G)
    
    y = log.(q)   
    
    fobj(b) = sum( (y - logdischarge.(rcfit(G,b[]), h)).^2 )

    res = optimize(fobj, [-Inf], [.99*minimum(h)], [rc₀.b])
    b = Optim.minimizer(res)[]
    
    rc = rcfit(G, b)
    
    return rc
    
end

"""
    rcfit(G::Vector{Gauging}, b::Real)

Fit the rating curve of parameter `b` to the gaugings `G`.
"""
function rcfit(G::Vector{Gauging}, b::Real)
     
    h = level.(G)
    q = discharge.(G)
    
    @assert b < minimum(h) 
    
    x = log.(h .- b)
    y = log.(q)
    
    X = hcat(ones(length(x)), x)
    
    β̂ = X\y
    
    c = β̂[2]
    
    a = exp(β̂[1])
    
    rc = RatingCurve(G, a, b, c)
    
    return rc
    
end

"""
    rcfit(G::Vector{Gauging}, constraint::AbstractVector{<:Real})

Fit the rating curve to the gaugings `G` passing through the point (h,q) specified in `constraint`.
"""
function rcfit(G::Vector{Gauging}, constraint::AbstractVector{<:Real})
    
    h = level.(G)
    q = discharge.(G)
    
    y = log.(q)
    
    rc₀ = RatingCurves.getinitialvalues(G)
    
    fobj(b) = sum( (y - logdischarge.(rcfit(G,b[],constraint), h)).^2 )

    res = optimize(fobj, [-Inf], [.99*minimum(h)], [rc₀.b])
    b = Optim.minimizer(res)[]
    
    rc = rcfit(G, b, constraint)
    
    return rc
    
end

"""
    rcfit(G::Vector{Gauging}, b::Real, constraint::AbstractVector{<:Real})

Fit the rating curve with parameter `b` to the gaugings `G` passing through the point (h,q) specified in `constraint`.
"""
function rcfit(G::Vector{Gauging}, b::Real, constraint::AbstractVector{<:Real})
   
    h = level.(G)
    q = discharge.(G)
    
    @assert b < minimum(h) 
    
    h̃ = constraint[1]
    q̃ = constraint[2]
    
    x̃ = log(h̃ - b)
    ỹ = log(q̃)
    
    x = log.(h .- b)
    y = log.(q)
    
    z = x .- x̃
    
    c = z\(y .- ỹ)
    
    a = exp(ỹ - x̃*c)
    
    rc = RatingCurve(G, a, b, c)
    
    return rc   
    
end