# Rating curve fitting

```@setup SainteAnne
using RatingCurves, DataFrames, Gadfly
data = RatingCurves.dataset("50408")
h = data.Level
q = data.Discharge
G = Gauging.(h,q)    
```

The following power-law relationship is used to model the level $(h)$ and discharge $(q)$ relationship:

```math
q = a \, (h-b)^c;
```
where $a>0$, $b \in \mathbb{R}$ and $c>0$ are the parameters. The function [`rcfit`](@ref) finds the parameter estimates for a set of gaugings. 


## Algorithm

 In the log space, the level-discharge relationship can be written as follows:
```math
\log q = \log a + c \log (h-b),
```
which is almost a simple linear regression model.

With a set of $n \geq 3$ gaugings $\{(h_i,q_i), 1 \leq i \leq n\}$, the optimal parameters $(a,b,c)$ are defined by the ones that minimize the sum of squares in the log space expressed as the following objective function:
```math
f_{obj}(a,b,c) = \sum_{i=1}^n \left\{ \log q_i - \log a - c \log (h_i-b) \right\}^2.
```

Conditional on $b$, the parameters $a$ and $c$ that minimize the sum of squares are the estimated linear regression coefficients. The search for the optimal $\left( -\infty < b < \min(h_i) \right)$ is performed with the [limited-memory Broyden–Fletcher–Goldfarb–Shanno algorithm](https://julianlsolvers.github.io/Optim.jl/stable/#algo/lbfgs/) (L-BFGS). For each of the candidates for $b$, the optimal values of $a$ and $c$ are calculated explicitly with the normal equations in linear regression.

## Fit on gaugings

The function [`rcfit`](@ref) can be called with the gauging levels and discharges:
```@repl SainteAnne
rc = rcfit(h,q)
```
The function returns a [`RatingCurve`](@ref) type.

!!! note
    The function [`rcfit`](@ref) can also be called with the vector of [`Gauging`](@ref) as argument.

The quality of the fit can be visually assessed in the log space:
```@example SainteAnne
x = log.(h .- rc.b)
y = log.(q)

plot(x=x, y=y, Geom.point, intercept=[log(rc.a)], slope=[rc.c], Geom.abline(color="red", style=:dash))
```
and in the original space:
```@example SainteAnne
obs = layer(data, x=:Level, y=:Discharge, Geom.point)
model = layer(h->discharge(rc, h), 26, 32, Theme(default_color=colorant"red"))
plot(obs, model)
```

## Discharge estimation

With the fitted rating curve, the discharge estimation at the level $h_0 = 29$ can be ontained with [`discharge`](@ref):
```@repl SainteAnne
discharge(rc, 29)
```

It is also possible to estimate the level corresponding to the discharge $q = 340$ with [`level`](@ref):
```@repl SainteAnne
level(rc, 340)
```


## Parameter uncertainty

The rating curve parameter uncertainty can be estimated by bootstrap with the function [`cint`](@ref). For the Sainte-Anne example, the 95% confidence intervals are estimated using 100 boostrap samples of the original gaugings:
```@example SainteAnne
res = cint(rc, nboot=100)
println(string("a ∈ [", res[1,1]," , ", res[2,1]," ]"))
println(string("b ∈ [", res[1,2]," , ", res[2,2]," ]"))
println(string("c ∈ [", res[1,3]," , ", res[2,3]," ]"))
```

!!! note
    In the bootstrap resampling procedure, the gauging with the minimum level is always selected so that the bootstrap rating curves are always defined on the original gauging range.

## Discharge uncertainty

The 95% confidence interval on the discharge estimation at $h_0 = 29$ can be obtained with [`pint`](@ref):
```@repl SainteAnne
pint(rc, 29)
```
For more details on how this uncerainty is estimated, see the description of [`pint`](@ref).

The confidence interval for the whole level range of the rating curve can be plotted as follows:
```@example SainteAnne
h₀ = range(minimum(data.Level), stop=32, length=100)

# Discharge estimation for each level 
q̂₀ = discharge.(rc, h₀)

# 95% confidence intervals of each discharge estimation
res = pint.(rc, h₀)

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

The BIC (Bayesian Information Criterion) is an index of the quality of the curve fit to the gaugings. Assuming that the errors are normally distributed in the log space, the BIC of the curve in log space can be obtained as follows:

`` \operatorname{bic} = n \log \hat\sigma_e^2 + 3 \log n,``

where ``n`` corresponds to the number of gaugings, ``\hat\sigma_e^2`` corresponds to the variance of the errors in the log space and the value 3 stands for the number of parameters.

The BIC of a fitted rating curve can be obtaines with the function [`bic`](@ref):
```@repl SainteAnne
bic(rc)
```

## Constrained rating curve fit

The rating curve can also be fit to the gaugings by requiring the curve to pass through a particular point. The curve obtained is the one that minimizes the sum of the squared errors among the curves that pass through the given point.

For example, if one wants the curve to pass through the last gauging, this constraint can be added by using [`rcfit`](@ref) with the contraint arguement:
```@example SainteAnne
# Extract the level and discharge of the last gauging
Gₘ = maximum(G)
h̃ = level(Gₘ)
q̃ = discharge(Gₘ)

# Fit the constrained curve
constrained_rc = rcfit(G, [h̃, q̃])
```

The constrained curve can be plotted in the usual way:
```@example SainteAnne
obs = layer(data, x=:Level, y=:Discharge, Geom.point)
model = layer(h->discharge(constrained_rc, h), 26, 32, Theme(default_color=colorant"red"))
plot(obs, model)
```

The confidence interval on the discharge estimations can also be obtained in the usual way:
```@example SainteAnne
h₀ = range(minimum(data.Level), stop=32, length=100)

# Discharge estimation for each level 
q̂₀ = discharge.(constrained_rc, h₀)

# 95% confidence intervals of each discharge estimation
res = pint.(constrained_rc, h₀)

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

