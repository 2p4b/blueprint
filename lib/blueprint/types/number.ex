defmodule Blueprint.Types.Number do

    def cast(value, _opts) when is_number(value) do
        {:ok, value}
    end

    def cast(value, _opts) when is_binary(value) do
        dvalue = String.trim(value)
        cond do
            String.match?(dvalue, ~r/^[0-9]+$/) ->
                {parsed, ""} = Integer.parse(dvalue)
                {:ok, parsed}

            String.match?(dvalue, ~r/^\d+\.\d+$/) ->
                {parsed, ""} = Float.parse(dvalue)
                {:ok, parsed}

            true ->
                cast(%{value: value}, [])
        end
    end

    def cast(_value, _opts) do
        {:error, ["invalid type number required"]}
    end

end

