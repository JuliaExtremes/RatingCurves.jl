module RatingCurves

using Optim, Random, Statistics

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
