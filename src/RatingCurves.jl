module RatingCurves

using CSV, DataFrames, Distributions, Optim, Random, Statistics, StatsBase

import Base.sort, Base.minimum, Base.maximum, Statistics.var, StatsBase.bic

include("data.jl")
include("structures.jl")
include("parameterestimation.jl")

export 

# Datatype
Gauging,
RatingCurve,
CompoundRatingCurve,

bic,
cint,
crcfit,
level,
discharge,
logdischarge,
minimum,
maximum,
pint,
pintlog,
rcfit,
sort

end
