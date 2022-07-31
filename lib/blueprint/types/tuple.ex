defmodule Blueprint.Types.Tuple do

    def cast(value, _opts) when is_tuple(value) do
        {:ok, value}
    end
    def cast(value, _opts) when is_list(value) do
        {:ok, List.to_tuple(value)}
    end

    def cast(_value, _opts) do
        {:error, ["invalid tuple"]}
    end

end

