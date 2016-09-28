# JSONify.jl

[![Build Status](https://travis-ci.org/joshbode/JSONify.jl.svg?branch=master)](https://travis-ci.org/joshbode/JSONify.jl)

[![Coverage Status](https://coveralls.io/repos/joshbode/JSONify.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/joshbode/JSONify.jl?branch=master)

[![codecov.io](http://codecov.io/github/joshbode/JSONify.jl/coverage.svg?branch=master)](http://codecov.io/github/joshbode/JSONify.jl?branch=master)ossless conversion of custom Julia objects to and from JSON.

This package was motivated by improving the de/serialization of DataFrames
from/to JSON. More types will be added as required.

## Example

Convert a DataFrame to JSON and back, preserving column types.

```julia
using JSONify
using DataFrames

data = DataFrame(a = ["a", "b", "c", "d"], b = rand(4), c = [1, 2, 3, 4])

x = JSON.json(data)                 # Convert DataFrame to JSON

data2 = DataFrame(JSON.parse(x))    # Parse x from JSON to DataFrame

data2 == data                       # true
```
