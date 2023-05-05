defmodule Blueprint.Type.String do

    @behaviour Blueprint.Type.Behaviour

    @impl Blueprint.Type.Behaviour
    def cast([], _opts) do
        {:error, ["invalid string"]}
    end

    @impl Blueprint.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts)  do
        try do
            {:ok, String.Chars.to_string(value)}
        rescue 
            Protocol.UndefinedError ->
              {:error, ["invalid string"]}
        end
    end

    @impl Blueprint.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end
