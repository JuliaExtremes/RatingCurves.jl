module RatingCurves

using Optim

include("structures.jl")
include("parameterestimation.jl")

export 

# Datatype
Gauging,
RatingCurve,
CompoundRatingCurve,

level,
discharge,
logdischarge,
rcfit

end
