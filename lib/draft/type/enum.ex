defmodule Draft.Type.Enum do

    @behaviour Draft.Type.Behaviour
    
    @impl Draft.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Draft.Type.Behaviour
    def cast(value, opts) when is_list(opts) do
        types = Keyword.fetch!(opts, :values)
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

    @impl Draft.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid enum value"]}
    end

    @impl Draft.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end
