module RatingCurves

using Distributions, Optim, Random, Statistics, StatsBase

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
