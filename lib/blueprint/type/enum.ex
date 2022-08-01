defmodule Blueprint.Type.Enum do

    def cast(nil, _opts) do
        {:ok, nil}
    end

    def cast(value, types) when is_list(types) do
        try do
            types_map = 
                types 
                |> Enum.map(fn val -> 
                    {String.Chars.to_string(val), val}
                end) 
                |> Enum.into(%{})

            string_value = String.Chars.to_string(value)

            case Map.fetch(types_map, string_value) do
                {:ok, value} ->
                      {:ok, value}
                _ ->
                  {:error, ["invalid enum value expected one of #{inspect(types)}"]}
            end
        rescue 
            Protocol.UndefinedError ->
              {:error, ["invalid enum value"]}
        end
    end

    def cast(_value, _opts) do
        {:error, ["invalid enum value"]}
    end

    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end


