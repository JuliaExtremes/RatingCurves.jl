module RatingCurves

using Optim, Statistics

import Statistics.var

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
