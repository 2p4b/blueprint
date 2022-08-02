defmodule Blueprint.Validator.Fields do
    use Blueprint.Validator

    def validate(values, options) when is_map(values) do
        validate(values, %{}, options)
    end

    def validate(values, _context, options) when is_map(values) do
        case Blueprint.results(values, options) do
            [] ->
                {:ok, values}

            errors ->
                {:error, errors}
        end
    end

    def validate(value, _context, options) do
        {:error, message(options, "must be string", value: value)}
    end

end
