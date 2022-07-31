defmodule Blueprint.Types.UUID do

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

end


