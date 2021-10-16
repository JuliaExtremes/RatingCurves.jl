"""
    dataset(name::String)::DataFrame

Load the dataset associated with `name`.

Some datasets available:
 - `50408`: Gauging (water levels and corresponding discharges) of the Sainte-Anne river in the province of Quebec (Canada).


# Examples
```julia-repl
julia> RatingCurves.dataset("50408")
```
"""
function dataset(name::String)::DataFrame

    filename = joinpath(dirname(@__FILE__), "..", "data", string(name, ".csv"))
    if isfile(filename)
        # return DataFrame!(CSV.File(filename))
        return CSV.read(filename, DataFrame)
    end
    error("There is no dataset with the name '$name'")

end