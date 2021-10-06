module RatingCurves

using Distributions, Optim, Random, Statistics, StatsBase

import Base.sort, Base.minimum, Base.maximum, Statistics.var, StatsBase.bic

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
minimum,
maximum,
rcfit,
sort

end
