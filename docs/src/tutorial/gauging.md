# Data

```@setup SainteAnne
using RatingCurves, DataFrames, Gadfly
```

## Load the data

Loading the annual gaugings of the Sainte-Anne river:
```@example SainteAnne
data = RatingCurves.dataset("50408")
first(data,5)
```

The gaugings can be shown as by plotting the discharges as function of the levels:
```@example SainteAnne
set_default_plot_size(12cm, 8cm)
plot(data, x=:Level, y=:Discharge, Geom.point)
```

## Construct the Gauging type

It is possible to construct a [`Gauging`](@ref) type with a level and discharge couple:
```@repl SainteAnne
h = data.Level[1]
q = data.Discharge[1]

G = Gauging(h,q)    
```

The level and the discharge of the gauging `G` can be retrieved with [`level`](@ref) and [`discharge`](@ref) methods respectively:
```@replSainteAnne
h = level(G)
q = discharge(G)
```

The constructor can be broadcasted to obtain a vector of type [`Gauging`](@ref):
```@repl SainteAnne
G = Gauging.(data.Level, data.Discharge)
```

The [`level`](@ref) and [`discharge`](@ref) methods can also be broadcasted. For example:
```@repl SainteAnne
discharge.(G)
```