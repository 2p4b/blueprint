defmodule Blueprint.Type.Atom do

    @behaviour Blueprint.Type.Behaviour
    
    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_atom(value) do
        {:ok, value}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_binary(value) do
        try do
            {:ok, String.to_existing_atom(value)}
        rescue 
            ArgumentError ->
              {:error, ["string atom value not found"]}
        end
    end

    @impl Blueprint.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid atom"]}
    end

    @impl Blueprint.Type.Behaviour
    def dump(val, opts \\ [])

    @impl Blueprint.Type.Behaviour
    def dump(nil, _opts) do
        {:ok, nil}
    end

    @impl Blueprint.Type.Behaviour
    def dump(value, _opts) when is_atom(value) do
        {:ok, String.Chars.to_string(value)}
    end

end

