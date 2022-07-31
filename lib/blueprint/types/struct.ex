defmodule Blueprint.Types.Struct do

    def cast(value, opts) when is_list(value) do
        cast(Enum.into(value, %{}), opts)
    end

    def cast(value, opts) when is_struct(value) do
        cast(Map.from_struct(value), opts)
    end


    def cast(value, [type|_]) when is_map(value) when is_atom(type) do
        cast(value, type)
    end

    def cast(value, type) when is_map(value) when is_atom(type) do
        {:ok, struct(type, value)}
    end

    def cast(_value, _opts) do
        {:error, ["invalid struct"]}
    end

end





