defmodule Blueprint.Type.Number do

    @behaviour Blueprint.Type.Behaviour
    
    @impl Blueprint.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when is_number(value) do
        {:ok, value}
    end

    @impl Blueprint.Type.Behaviour
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

    @impl Blueprint.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid type number required"]}
    end

    @impl Blueprint.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end
