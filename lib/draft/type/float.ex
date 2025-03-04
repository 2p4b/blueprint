defmodule Draft.Type.Float do

    @behaviour Draft.Type.Behaviour
    
    @impl Draft.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Draft.Type.Behaviour
    def cast(value, _opts) when is_float(value) do
        {:ok, value}
    end

    @impl Draft.Type.Behaviour
    def cast(value, _opts) when is_number(value) do
        {:ok, value/1.00}
    end

    @impl Draft.Type.Behaviour
    def cast(value, _opts) when is_binary(value) do
        dvalue = String.trim(value)
        if String.match?(dvalue, ~r/^\d+\.\d+$/) do
            {parsed, ""} = Float.parse(dvalue)
            {:ok, parsed}
        else
            cast(%{value: value}, [])
        end
    end

    @impl Draft.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid integer"]}
    end

    @impl Draft.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end
