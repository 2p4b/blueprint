defmodule Blueprint.Type.Struct do

    @behaviour Blueprint.Type.Behaviour
    
    @impl Blueprint.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, opts) when is_list(value) do
        cast(Enum.into(value, %{}), opts)
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, opts) when is_struct(value) do
        cast(Map.from_struct(value), opts)
    end


    @impl Blueprint.Type.Behaviour
    def cast(value, [type|_]) when is_map(value) when is_atom(type) do
        cast(value, type)
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, type) when is_map(value) when is_atom(type) do
        {:ok, struct(type, value)}
    end

    @impl Blueprint.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid struct"]}
    end

    @impl Blueprint.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end
