
# Compound rating curve fitting

The compound power-law level-discharge relationship for two segments is given as folows:
```math
q = \begin{cases}
a_1 \, (h-b_1)^{c_1} & \text{ if  } h < k, \\
a_2 \, (h-b_2)^{c_2} & \text{ if  } h \geq k.
\end{cases}
```

```@setup SainteAnne
using RatingCurves, DataFrames, Gadfly
data = RatingCurves.dataset("50408")
h = data.Level
q = data.Discharge
G = Gauging.(h,q)    
```

## Algorithm

For a given k, the rating curve for large discharges is fitted to the gaugings whose level is greater than or equal to ``k``. The parameters ``(a_2, b_2, c_2)`` are therefore estimated. For levels less than ``k``, the rating curve is fitted to the gaugings whose level is less than ``k`` by imposing that curve passes through the point ``(k, a_2(k-b_2)^{c_2})`` to ensure continuity between the two segments. The search for the optimal ``k`` is performed with the [limited-memory Broyden–Fletcher–Goldfarb–Shanno algorithm](https://julianlsolvers.github.io/Optim.jl/stable/#algo/lbfgs/) (L-BFGS).

!!! note
    In order to have enough observations for the estimation of the curve of each of the segments, the search for the optimal k is limited between the level of the third smallest gauging and the third largest gauging.

See also [`rcfit`](@ref).

## Fit on gaugings

The function [`crcfit`](@ref) can be called with the gauging levels and discharges:
```@repl SainteAnne
crc = crcfit(h,q)
```
The function returns a [`CompoundRatingCurve`](@ref) type.

!!! note
    The function [`crcfit`](@ref) can also be called with the vector of [`Gauging`](@ref) as argument.

The quality of the fit can be visually assessed in the log space:
```@example SainteAnne
x = log.(data.Level)
y = log.(data.Discharge)

obs = layer(x=x, y=y, Geom.point)
model = layer(x->logdischarge(crc, exp(x)), log(26), log(32), Theme(default_color=colorant"red"))
plot(obs, model, Coord.cartesian(ymin=2, ymax=7))
```
and in the original space:
```@example SainteAnne
obs = layer(data, x=:Level, y=:Discharge, Geom.point)
model = layer(h->discharge(crc, h), 26, 32, Theme(default_color=colorant"red"))
plot(obs, model, Coord.cartesian(ymin=0, ymax=1000))
```