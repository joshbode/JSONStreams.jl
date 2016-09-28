"""
Extensions for JSON for additional data types
"""
module JSONify

using Requires
import JSON: _writejson, State

"""
    subtypesearch(T::DataType)

Returns: Array of all non-abstract and non-parametrised subtypes of the type `T`.

This function searches recursively through the type hierarchy, whereas `Base.subtypes` searches just 1 level down.

`subtypesearch(concrete_type)` returns an array containing only `concrete_type`.
"""
function subtypesearch(T::DataType)
    function st(T::DataType)
        if isleaftype(T) && isempty(T.parameters)
            produce(T)
        end
        for S in sort(subtypes(T), by=(T) -> (T.size, string(T.name)))
            st(S)
        end
    end
    collect(Task(() -> st(T)))
end

# JSON-serialisable types
json_types = append!([String, Char, Date, DateTime], subtypesearch(Number))
type_map = Dict{String, DataType}(zip([lowercase(string(t.name)) for t in json_types], json_types))

function _writejson(io::IO, state::State, a::DataType)
    if !in(a, json_types)
        throw(ArgumentError("Cannot serialise type: $a"))
    end
    _writejson(io, state, lowercase(string(a.name)))
end

@require DataFrames begin

    """
        DataFrame(data::Dict{String, Vector{Any}})

    Convert dictionary of Arrays to a `DataFrame`.

    The dict is typically constructed by `JSON.parse(JSON.json(my_dataframe))`.

    Assumes a dictionary in the form:
    ```julia
    Dict(
        "names" => Vector{Union{String, Symbol}}(...),
        "types" => Vector{String}(...),
        "columns" => Vector{Any}(...)
    )
    ```
    where

    * `names`: the names of the columns.
    * `types`: the types of the columns.
    * `columns`: the data in the columns.

    and each array is of the same length.
    """
    function DataFrames.DataFrame(data::Dict{String, Any})
        names, types, columns = try
            data["names"], data["types"], data["columns"]
        catch e
            throw(InputError("Missing value: $(e.key)"))
        end

        df = DataFrames.DataFrame()

        for (name, type_name, column) in zip(names, types, columns)
            n = length(column)
            # construct empty DataArray (initially all values are `NA`)
            array = df[Symbol(name)] = DataArrays.DataArray(get(type_map, type_name, Any), n)
            for i = 1:n
                value = column[i]
                # populate if data provided, otherwise leaves value as `NA`
                if value != nothing
                    array[i] = value
                end
            end
        end
        df
    end

    # Custom JSON renderers

    """
    JSONify a DataFrame.

    Converts the DataFrame to a Dict first.
    """
    function _writejson(io::IO, state::State, a::DataFrames.DataFrame)
        # write data out in format of DataFrame converter
        _writejson(io, state, Dict{Symbol, Vector{Any}}(
            :names => DataFrames.names(a),
            :types => DataFrames.eltypes(a),
            :columns => DataFrames.columns(a)
        ))
    end

end

@require DataArrays begin

    """
    JSONify `NAtype` to `null`.
    """
    function _writejson(io::IO, state::State, a::DataArrays.NAtype)
        Base.print(io, "null")
    end

end

# more (de)serialisers added as needed

end
