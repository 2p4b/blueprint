defmodule Blueprint.Type.Integer do

    def cast(nil, _opts) do
        {:ok, nil}
    end

    def cast(value, _opts) when is_integer(value) do
        {:ok, value}
    end

    def cast(value, _opts) when is_float(value) do
        {:ok, trunc(value)}
    end

    def cast(value, _opts) when is_binary(value) do
        dvalue = String.trim(value)
        if String.match?(dvalue, ~r/^[0-9]+$/) do
            {parsed, ""} = Integer.parse(dvalue)
            {:ok, parsed}
        else
            cast(%{value: value}, [])
        end
    end

    def cast(_value, _opts) do
        {:error, ["invalid integer"]}
    end

    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end


