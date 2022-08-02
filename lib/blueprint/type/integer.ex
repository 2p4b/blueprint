defmodule Blueprint.Type.Integer do

    @behaviour Blueprint.Type.Behaviour
    
    @impl Blueprint.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_integer(value) do
        {:ok, value}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_float(value) do
        {:ok, trunc(value)}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_binary(value) do
        dvalue = String.trim(value)
        if String.match?(dvalue, ~r/^[0-9]+$/) do
            {parsed, ""} = Integer.parse(dvalue)
            {:ok, parsed}
        else
            cast(%{value: value}, [])
        end
    end

    @impl Blueprint.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid integer"]}
    end

    @impl Blueprint.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end
