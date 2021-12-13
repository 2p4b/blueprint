defmodule Blueprint.Validators.Struct do
    use Blueprint.Validator

    def validate(value, options) when is_list(options) do
        validate(value, nil, options)
    end

    @message_fields [value: "The bad value"]
    def validate(value, context, func) when is_function(func),
    do: validate(value, context, function: func)

    def validate(value, context, options)
    when is_map(options) or is_atom(options) do
        validate(value, context, struct: options)
    end

    def validate(%{__struct__: vtype}=value, _context, options)
    when is_struct(value) and is_list(options) do
        case Keyword.get(options, :struct) do
            type when vtype !== type ->
                messg =
                    options
                    |> message("must be #{inspect(type)} struct", value: value)
                {:error, messg}

            type when is_atom(type) ->
                case Blueprint.errors(value) do
                    [] -> :ok

                    errors ->
                        {:error, errors}
                end

            schema when is_map(schema) ->
                case Blueprint.errors(value, Map.to_list(options)) do
                    [] -> :ok

                    errors ->
                        {:error, errors}
                end


            _ ->
                {:error, :bad_options_args}
        end
    end


    def validate(value, _context, options)
    when is_map(options) or is_list(options) do
        type = Keyword.get(options, :struct)
        {:error, message(options, "must be #{inspect(type)} struct", value: value)}
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
