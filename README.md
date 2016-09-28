# JSONify.jl

Lossless conversion of custom Julia objects to and from JSON.

[![Build Status](https://travis-ci.org/joshbode/JSONify.jl.svg?branch=master)](https://travis-ci.org/joshbode/JSONify.jl)

[![Coverage Status](https://coveralls.io/repos/joshbode/JSONify.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/joshbode/JSONify.jl?branch=master)

[![codecov.io](http://codecov.io/github/joshbode/JSONify.jl/coverage.svg?branch=master)](http://codecov.io/github/joshbode/JSONify.jl?branch=master)

This package was motivated by improving the de/serialization of DataFrames
from/to JSON. More types will be added as required.

## Example

Convert a DataFrame to JSON and back, preserving column types.

```julia
using JSONify
using DataFrames


# Complete data
data  = DataFrame(a = ["a", "b", "c", "d"], b = rand(4), c = [1, 2, 3, 4])
x     = JSON.json(data)             # Convert DataFrame to JSON
data2 = DataFrame(JSON.parse(x))    # Parse x from JSON to DataFrame
data2 == data                       # true
eltypes(data2) == eltypes(data)     # true, types are preserved


# Missing data
data[1, :a] = NA
data
x     = JSON.json(data)
data2 = DataFrame(JSON.parse(x))
isequal(data2, data)                # true
eltypes(data2) == eltypes(data)     # true
```
