defmodule Blueprint.Types.Integer do

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

end


