using Base.Test
using JSONify
using DataFrames


data  = DataFrame(a = ["a", "b", "c", "d"], b = rand(4), c = [1, 2, 3, 4])
x     = JSON.json(data)             # Convert DataFrame to JSON
data2 = DataFrame(JSON.parse(x))    # Parse x from JSON to DataFrame
@test data2 == data
