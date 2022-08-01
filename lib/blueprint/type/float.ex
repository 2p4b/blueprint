defmodule Blueprint.Type.Float do

    @behaviour Blueprint.Type.Behaviour
    
    @impl Blueprint.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_float(value) do
        {:ok, value}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_number(value) do
        {:ok, value/1.00}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_binary(value) do
        dvalue = String.trim(value)
        if String.match?(dvalue, ~r/^\d+\.\d+$/) do
            {parsed, ""} = Float.parse(dvalue)
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

