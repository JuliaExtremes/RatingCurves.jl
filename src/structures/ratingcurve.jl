
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
    Base.show(io::IO, obj::EVA)
Override of the show function for the objects of type RatingCurve.
"""
function Base.show(io::IO, obj::RatingCurve)

    showRatingCurve(io, obj)

end

function showRatingCurve(io::IO, obj::RatingCurve)

    println(io, "RatingCurve")
    println(io, "   ", "data: ", typeof(obj.gauging), "[", length(obj.gauging), "]")
    println(io, "   ", "Parameters:")
    println(io, "      ", "a = ", obj.a)
    println(io, "      ", "b = ", obj.b)
    println(io, "      ", "c = ", obj.c)

end