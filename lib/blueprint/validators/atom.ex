defmodule Blueprint.Validators.Atom do
    use Blueprint.Validator

    def validate(value, options) when is_list(options) do
        validate(value, nil, options)
    end

    def validate(value, context, options)
    when is_map(options) or is_atom(options) do
        validate(value, context, atom: options)
    end

    def validate(value, _context, _options) when is_atom(value) do
        :ok
    end

    def validate(value, _context, options) do
        {:error, message(options, "must be an atom", value: value)}
    end

end

