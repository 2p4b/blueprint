defmodule Blueprint.Validators.String do
    use Blueprint.Validator

    def validate(value, options) when is_list(options) do
        validate(value, nil, options)
    end

    def validate(value, context, options)
    when is_map(options) or is_atom(options) do
        validate(value, context, string: options)
    end

    def validate(value, _context, options)
    when is_binary(value) and is_list(options) do
        :ok
    end

    def validate(value, _context, options) do
        {:error, message(options, "must be string", value: value)}
    end

end


