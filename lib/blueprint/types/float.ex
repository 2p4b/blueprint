defmodule Blueprint.Types.Float do

    def cast(value, _opts) when is_float(value) do
        {:ok, value}
    end

    def cast(value, _opts) when is_number(value) do
        {:ok, value/1.00}
    end

    def cast(value, _opts) when is_binary(value) do
        dvalue = String.trim(value)
        if String.match?(dvalue, ~r/^\d+\.\d+$/) do
            {parsed, ""} = Float.parse(dvalue)
            {:ok, parsed}
        else
            cast(%{value: value}, [])
        end
    end

    def cast(_value, _opts) do
        {:error, ["invalid integer"]}
    end

end

