defmodule Blueprint.Validators.By do
    use Blueprint.Validator

    def validate(value, fun), do: validate(value, nil, fun)

    @message_fields [value: "The bad value"]
    def validate(value, context, func) when is_function(func),
    do: validate(value, context, function: func)

    def validate(value, context, func) when is_struct(context) and is_atom(func) do
        validate(value, context, function: fn value, context -> 
            Kernel.apply(context.__struct__, func, [value, context])
        end)
    end

    def validate(value, context, options) when is_list(options) do
        unless_skipping(value, options) do
            function = Keyword.get(options, :function)

            case call_function(function, value, context) do
                {:error, reason} ->
                    {:error, reason}

                _ ->
                    {:ok, value}
            end
        end
    end

    defp call_function(f, value, _context) when is_function(f, 1), do: f.(value)
    defp call_function(f, value, context) when is_function(f, 2), do: f.(value, context)
end
