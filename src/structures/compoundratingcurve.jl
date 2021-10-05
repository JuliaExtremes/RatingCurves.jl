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