defmodule Blueprint.Validators.List do
    use Blueprint.Validator

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
            type when is_atom(type) ->

                is_struct_type = 
                    with [char|_] = Atom.to_string(type) |> String.codepoints() do
                        char |> String.upcase() === char
                    end

                invalid_index =
                    Enum.find_index(value, fn val -> 
                        if is_struct_type do
                            !Blueprint.valid?([value: val], value: [struct: type])
                        else
                            !Blueprint.valid?(val, [{type, true}])
                        end
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



