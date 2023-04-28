defmodule Blueprint.Validator.Fields do
    use Blueprint.Validator

    def validate(values, options) when is_map(values) do
        validate(values, %{}, options)
    end

    def validate(values, _context, options) when is_map(values) do
        opts = clean_opts(options)
        case Blueprint.results(values, opts) do
            [] ->
                {:ok, values}

            errors ->
                {:error, errors}
        end
    end

    def validate(value, _context, options) do
        {:error, message(options, "must be map", value: value)}
    end

    defp clean_opts(options) when is_map(options) do
        clean_opts(Map.to_list(options)) 
    end

    defp clean_opts(options) when is_list(options) do
        Enum.map(options, fn 
            # Make empty options field with only type definition
            # like [field: :type]
            {field, type} when is_atom(type) -> 
                  {field, []}

            # tuple opts [field: [:type, requried: true]] 
            # list opts [field: [:type, requried: true, length: :long ]]
            {field, [type| opts]} 
            when is_atom(type) and (is_tuple(opts) or is_list(opts)) -> 
                  {field, List.wrap(opts)}

            # list opts [field: [requried: true, length: :long ]]
            {field, [{vtype, _vopts}| ropts]=opts} 
            when is_atom(vtype) and is_list(ropts) -> 
                  {field, opts}
        end)     
    end

end
