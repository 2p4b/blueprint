defmodule Blueprint.Validator.Type do
    use Blueprint.Validator

    def validate(values, options) when is_list(values) do
        validate(values, %{}, options)
    end

    def validate(values, _context, options) when is_list(values) do
        indexed_values = 
            values
            |> Enum.with_index()
        case options do
            {:map, typeopts} ->
                results =
                    indexed_values
                    |> Enum.reduce([], fn {value, index}, acc -> 
                        rules = Keyword.get(typeopts, :fields)
                        case Blueprint.results(value, rules) do
                            [] ->
                                acc

                            errors ->
                                acc ++ [{index, errors}]
                        end
                    end)

                if Enum.empty?(results) do
                    {:ok, values}
                else
                    {:error, results}
                end

            type when is_atom(type) ->
                results =
                    indexed_values
                    |> Enum.reduce([], fn {value, index}, acc -> 
                        if is_struct(value) do
                            case Blueprint.results(value) do
                                [] ->
                                    acc

                                errors ->
                                    acc ++ [{index, errors}]
                            end
                        else
                            acc
                        end
                    end)

                if Enum.empty?(results) do
                    {:ok, values}
                else
                    {:error, results}
                end

        end
    end

    def validate(value, _context, options) do
        {:error, message(options, "must be string", value: value)}
    end

end
