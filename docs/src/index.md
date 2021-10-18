

# Rating curve fitting in Julia

*RatingCurves.jl* provides exhaustive high-performance functions for fitting power-law rating curves in Julia, such as:
* Fitting power-law rating curve to gaugings by minimizing the total sum of squares in the log space.
* Fitting compound power-law rating curve to gaugings by minimizing the total sum of squares in the log space.
* Computing the parameter uncertainties.
* Computing the discharge prediction uncertainty.


The power-law level-discharge relationship is given as folows:
```math
q = a \, (h-b)^c.
```

The compound power-law level-discharge relationship for two segments is given as folows:
```math
q = \begin{cases}
a_1 \, (h-b_1)^{c_1} & \text{ if  } h < h_0, \\
a_2 \, (h-b_2)^{c_2} & \text{ if  } h \geq h_0.
\end{cases}
```