defmodule Blueprint.Validators.List do
    use Blueprint.Validator

    @native_types [:number, :integer, :boolean, :float, :string, :struct]

    def validate(value, options) when is_list(options) do
        validate(value, nil, options)
    end

    def validate(value, context, options)
    when is_map(options) or is_atom(options) do
        validate(value, context, list: options)
    end

    def validate(value, _context, options)
    when is_list(value) and is_list(options) do
        list_type = Keyword.get(options, :of)
        case list_type do
            type when is_atom(type) and type in @native_types ->
                invalid_index =
                    Enum.find_index(value, fn val -> 
                        !Blueprint.valid?(val, [{type, true}])
                    end)
                if is_nil(invalid_index) do
                    :ok
                else
                    msg = "invalid list value at #{invalid_index}"
                    {:error, message(options, msg, value: value)}
                end

            # If type is not a native type then
            # type must be a struct
            type when is_atom(type) ->
                invalid_index =
                    Enum.find_index(value, fn val -> 
                        !Blueprint.valid?([value: val], value: [struct: type])
                    end)

                if is_nil(invalid_index) do
                    :ok
                else
                    msg = "invalid list #{inspect(type)} at #{invalid_index}"
                    {:error, message(options, msg, value: value)}
                end

            type ->
                msg = "invalid list type #{type}"
                {:error, message(options, msg, value: value)}
        end
    end

    def validate(value, _context, options) do
        {:error, message(options, "must be string", value: value)}
    end

end



