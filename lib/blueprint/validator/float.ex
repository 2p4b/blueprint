defmodule Blueprint.Validator.Float do
    use Blueprint.Validator

    def validate(value, options) when is_list(options) do
        validate(value, nil, options)
    end

    def validate(value, context, options)
    when is_map(options) or is_atom(options) do
        validate(value, context, float: options)
    end

    def validate(value, _context, options)
    when is_float(value) and is_list(options) do
        {:ok, value}
    end

    def validate(value, _context, options) do
        {:error, message(options, "must be float", value: value)}
    end

end



