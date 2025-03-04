defmodule Draft.Type.Atom do

    @behaviour Draft.Type.Behaviour
    
    @impl Draft.Type.Behaviour
    def cast(value, _opts) when is_atom(value) do
        {:ok, value}
    end

    @impl Draft.Type.Behaviour
    def cast(value, _opts) when is_binary(value) do
        try do
            {:ok, String.to_existing_atom(value)}
        rescue 
            ArgumentError ->
              {:error, ["string atom value not found"]}
        end
    end

    @impl Draft.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid atom"]}
    end

    @impl Draft.Type.Behaviour
    def dump(val, opts \\ [])

    @impl Draft.Type.Behaviour
    def dump(nil, _opts) do
        {:ok, nil}
    end

    @impl Draft.Type.Behaviour
    def dump(value, _opts) when is_atom(value) do
        {:ok, String.Chars.to_string(value)}
    end

end
