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