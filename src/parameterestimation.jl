
"""
crcfit(h::AbstractVector{<:Real}, q::AbstractVector{<:Real})

Fit the compound rating curve to the discharges `q` corresponding to the level `h`.
"""
function crcfit(h::AbstractVector{<:Real}, q::AbstractVector{<:Real})

@assert length(h)==length(q)

G = Gauging.(h,q)

crc = crcfit(G)

return crc

end


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