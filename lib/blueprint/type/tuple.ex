defmodule Blueprint.Type.Tuple do

    def cast(nil, _opts) do
        {:ok, nil}
    end

    def cast(value, _opts) when is_tuple(value) do
        {:ok, value}
    end

    def cast(value, _opts) when is_list(value) do
        {:ok, List.to_tuple(value)}
    end

    def cast(_value, _opts) do
        {:error, ["invalid tuple"]}
    end

    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end

