defmodule Blueprint.Validators.Value do
    use Blueprint.Validator

    def validate(value, options) when is_list(options) do
        validate(value, nil, options)
    end

    def validate(_value, _context, _options) do
        :ok
    end

end

