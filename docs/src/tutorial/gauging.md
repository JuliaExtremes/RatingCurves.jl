# Data

```@setup SainteAnne
using RatingCurves, DataFrames, Gadfly
```

## Load the data

Loading the annual gaugings of the Sainte-Anne river:
```@example SainteAnne
data = Extremes.dataset("50408")
first(data,5)
```

The gaugings can be shown as by plotting the discharges as function of the levels:
```@example SainteAnne
set_default_plot_size(12cm, 8cm)
plot(data, x=:Level, y=:Discharge, Geom.point)
```

## Construct the Gauging type

It is possible to construct a [`Gauging`](@ref) type with a level and discharge couple:
```@example SainteAnne
h = data.level[1]
q = data.Discharge[1]

G = Gauging(h,q)    
```
