defmodule Blueprint.Validators.Integer do
    use Blueprint.Validator

    def validate(value, options) when is_list(options) do
        validate(value, nil, options)
    end

    def validate(value, context, options)
    when is_map(options) or is_atom(options) do
        validate(value, context, integer: options)
    end

    def validate(value, _context, _options) when is_integer(value) do
        {:ok, value}
    end

    def validate(value, _context, options) do
        {:error, message(options, "must be integer", value: value)}
    end

end




