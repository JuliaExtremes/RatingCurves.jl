"""
    rcfit(h::AbstractVector{<:Real}, q::AbstractVector{<:Real})

Fit the rating curve to the discharges `q` corresponding to the level `h`.
"""
function rcfit(h::AbstractVector{<:Real}, q::AbstractVector{<:Real})
    
    @assert length(h)==length(q)
    
    G = Gauging.(h,q)
    
    rc = rcfit(G)
    
    return rc
    
end