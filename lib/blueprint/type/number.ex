defmodule Blueprint.Type.Number do

    def cast(nil, _opts) do
        {:ok, nil}
    end

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

    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end

