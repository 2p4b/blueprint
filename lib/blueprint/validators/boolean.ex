defmodule Blueprint.Validators.Boolean do
    use Blueprint.Validator

    def validate(value, options) when is_list(options) do
        validate(value, nil, options)
    end

    @message_fields [value: "The bad value"]
    def validate(value, context, func) when is_function(func),
    do: validate(value, context, function: func)

    def validate(value, context, options)
    when is_map(options) or is_atom(options) do
        validate(value, context, boolean: options)
    end

    def validate(value, _context, options)
    when is_boolean(value) and is_list(options) do
        :ok
    end


    def validate(value, _context, options) do
        {:error, message(options, "must be boolean", value: value)}
    end

end

