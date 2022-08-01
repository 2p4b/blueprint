defmodule Blueprint.Type.UUID do

    def cast(nil, _opts) do
        {:ok, nil}
    end

    def cast(value, _opts) when is_binary(value) do
        dvalue = String.trim(value)
        case UUID.info(dvalue) do
            {:ok, info} ->
                  {:ok, Keyword.get(info, :uuid)}
            _ ->
              cast(%{value: value}, [])
        end
    end

    def cast(_value, _opts) do
        {:error, ["invalid uuid"]}
    end

    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end


