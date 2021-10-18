
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

## Discharge estimation

With the fitted compound rating curve, the discharge estimation at the level $h_0 = 29$ can be ontained with [`discharge`](@ref):
```@repl SainteAnne
discharge(crc, 29)
```

It is also possible to estimate the level corresponding to the discharge $q = 340$ with [`level`](@ref):
```@repl SainteAnne
level(crc, 340)
```

## Parameter uncertainty

The compound rating curve parameter uncertainty can be estimated by bootstrap with the function [`cint`](@ref). For the Sainte-Anne example, the 95% confidence intervals are estimated using 100 boostrap samples of the original gaugings:
```@example SainteAnne
res = cint(crc, nboot=100)
println(string("k ∈ [", res[1,1]," , ", res[2,1]," ]"))
println(string("a₁ ∈ [", res[1,2]," , ", res[2,2]," ]"))
println(string("b₁ ∈ [", res[1,3]," , ", res[2,3]," ]"))
println(string("c₁ ∈ [", res[1,4]," , ", res[2,4]," ]"))
println(string("a₂ ∈ [", res[1,5]," , ", res[2,5]," ]"))
println(string("b₂ ∈ [", res[1,6]," , ", res[2,6]," ]"))
println(string("c₂ ∈ [", res[1,7]," , ", res[2,7]," ]"))
```

!!! note
    In the bootstrap resampling procedure, the gauging with the minimum level is always selected to ensure that the bootstrap rating curves are always defined on the original gauging level range.

## Discharge uncertainty

The 95% confidence interval on the discharge estimation at $h_0 = 29$ can be obtained with [`pint(::CompoundRatingCurve, ::Real, ::Real, ::Real)`](@ref):
```@repl SainteAnne
pint(crc, 29)
```
For more details on how this uncertainty is estimated, see the description of [`pint(::RatingCurve, ::Real, ::Real, ::Real)`](@ref).

The confidence interval for the whole level range of the rating curve can be plotted as follows:
```@example SainteAnne
h₀ = range(minimum(data.Level), stop=32, length=100)

# Discharge estimation for each level 
q̂₀ = discharge.(crc, h₀)

# 95% confidence intervals of each discharge estimation
res = pint.(crc, h₀)

# Lower bound of interval
qmin = getindex.(res,1)

# Upper bound of interval
qmax = getindex.(res,2)

# Plotting the interval and the gaugings 
obs = layer(data, x=:Level, y=:Discharge, Geom.point)
model = layer(x=h₀, y=q̂₀, Geom.line,
    ymin = qmin, ymax = qmax, Geom.ribbon,
    Theme(default_color=colorant"red"))

plot(obs, model)
```   

## Fit quality assessment

The BIC (Bayesian Information Criterion) is an index of the quality of the curve fit to the gaugings. Assuming that the errors are normally distributed in the log space for each segment, the BIC of the compund curve in the log space can be obtained as follows:

`` \operatorname{bic} = n_1 \log \hat\sigma_{e1}^2 + n_2 \log \hat\sigma_{e2}^2+ 6 \log n,``

where ``n_1`` and ``n_2`` correspond to the number of gaugings of the first and second segment respectively, ``\hat\sigma_{e1}^2`` and ``\hat\sigma_{e2}^2`` correspond to the variance of the errors in the log space for the first and second segment respectively, ``n`` corresponds to the total number of gauging and the value 6 stands for the number of parameters.

The BIC of a fitted compound rating curve can be obtained with the function [`bic`](@ref):
```@repl SainteAnne
bic(crc)
```

## Compound rating curve fit with a known breakpoint

If the breakpoint ``k`` is known by the investigator, the rating curves of the two segments can be fitted with [`crcfit`](@ref) by specifying the optional argument `k`. For example, let suppose that the breakpoint for the Sainte-Anne data is at ``k = 28``, then the compoud rating curve can be obtained as follows:
```@repl SainteAnne
crcfit(G, 28)
```