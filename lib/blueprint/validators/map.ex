defmodule Blueprint.Validators.Map do
    use Blueprint.Validator

    @message_fields [value: "The bad value"]
    def validate(value, func) when is_function(func) do
        validate(value, function: func)
    end

    def validate(value, options) when is_list(options) do
        validate(value, nil, options)
    end

    @message_fields [value: "The bad value"]
    def validate(value, context, func) when is_function(func),
    do: validate(value, context, function: func)

    def validate(value, _context, options)
    when is_map(value) and is_map(options) do
        case Blueprint.errors(value, Map.to_list(options)) do
            [] ->
                :ok
            errors ->
                {:error, errors}
        end
    end

    def validate(value, _context, options) when is_map(options) do
        {:error, message(options, "must be map", value: value)}
    end

    def validate(value, context, options) when is_list(options) do
        unless_skipping(value, options) do
            function = Keyword.get(options, :function)

            case call_function(function, value, context) do
                {:error, reason} ->
                    {:error, reason}

                falsy when falsy === false or falsy === nil ->
                    {:error, message(options, "must be valid", value: value)}

                _ ->
                    :ok
            end
        end
    end

    defp call_function(f, value, _context) when is_function(f, 1), do: f.(value)
    defp call_function(f, value, context) when is_function(f, 2), do: f.(value, context)
end
