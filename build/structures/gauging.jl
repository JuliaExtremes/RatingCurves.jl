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
    bootstrap(G::Vector{Gauging})

Resample the gauging for bootstrap.

### Details

Sampling with replacement is performed to compose a gauging sample of the same size. 
The smallest gauging is always selected so that the rating curve is valid over the entire gauged range.
"""
function bootstrap(G::Vector{Gauging})
    
    n = length(G)
    
    G_bootstrap = sample(G, n-1, replace=true)
    
    pushfirst!(G_bootstrap, minimum(G))
    
    return G_bootstrap
    
end


"""
    crcfit(G::Vector{Gauging})

Fit the compound rating curve corresponding to the gaugings `G`
"""
function crcfit(G::Vector{Gauging})
    
    h = level.(G)
    q = discharge.(G) 
    
    hs = sort(unique(h))
    
    fobj(k) = sum( (log.(q) - logdischarge.(crcfit(G,k), h)).^2 )
    res = optimize(fobj, hs[3]+1e-6, hs[end-2]-1e-6)
    k = Optim.minimizer(res)
    
    crc = crcfit(G, k)
    
    return crc
    
end

"""
    crcfit(G::Vector{Gauging},k::Real)

Fit the compound rating curve corresponding to the gaugings `G` using the break-point `k`.

### Details

At least 3 gaugings are necessary by component of the compound rating curve.
"""
function crcfit(G::Vector{Gauging}, k::Real)
   
    h = level.(G)
    q = discharge.(G)
    
    ind = h.>k
    
    h2 = h[ind]
    q2 = q[ind]
    G₂ = G[ind]
    
    h1 = h[.!(ind)]
    q1 = q[.!(ind)]
    G₁ = G[.!(ind)]
    
    rc₂ = rcfit(G₂)
    
    # Continuity constraint at h = k
    rc₁ = rcfit(G₁, [k, discharge(rc₂, k)])
    
    crc = CompoundRatingCurve([k], [rc₁, rc₂] )
    
    return crc
    
end

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
    minimum(G::Vector{Gauging})

Return the gauging with the smallest level.
"""
function minimum(G::Vector{Gauging})
    
    ind = argmin(level.(G))
    
    return G[ind]
end


"""
    maximum(G::Vector{Gauging})

Return the gauging with the highest level.
"""
function maximum(G::Vector{Gauging})
    
    ind = argmax(level.(G))
    
    return G[ind]
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

"""
    sort(G::Vector{Gauging}; rev::Bool=false)

Sort the gauging according to the level.

### Details

Sort in ascending order if `rev=false` (option by default) and in descendinf order if `rev=true`.
"""
function sort(G::Vector{Gauging}; rev::Bool=false)
   
    h = level.(G)
    
    Gs = G[sortperm(h, rev=rev)]
    
    return Gs
    
end