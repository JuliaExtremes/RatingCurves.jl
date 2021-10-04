module RatingCurves

using Optim

include("structures.jl")
include("parameterestimation.jl")

export 

# Datatype
Gauging,
RatingCurve,
CompoundRatingCurve,

crcfit,
level,
discharge,
logdischarge,
rcfit

end
