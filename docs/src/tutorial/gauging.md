# Gauging type

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