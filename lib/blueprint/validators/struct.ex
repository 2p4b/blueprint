defmodule Blueprint.Validators.Struct do
    use Blueprint.Validator

    def validate(%{__struct__: vtype}=struct, type) when vtype === type do
        {:ok, struct}
    end

    def validate(_value, _context, type) when is_atom(type) do
        {:error, "must be #{inspect(type)} struct"}
    end

end
