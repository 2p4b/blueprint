defmodule Blueprint.Type.Tuple do

    @behaviour Blueprint.Type.Behaviour
    
    @impl Blueprint.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_tuple(value) do
        {:ok, value}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_list(value) do
        {:ok, List.to_tuple(value)}
    end

    @impl Blueprint.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid tuple"]}
    end

    @impl Blueprint.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end

