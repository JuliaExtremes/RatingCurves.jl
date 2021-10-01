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
        println(io, "   for ",threshold[i]," < h ≤ ",threshold[i+1])
        showRatingCurve(io, obj.component[i],"      ")
    end
end