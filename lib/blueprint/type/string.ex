defmodule Blueprint.Type.String do

    def cast([], _opts) do
        {:error, ["invalid string"]}
    end

    def cast(nil, _opts) do
        {:ok, nil}
    end

    def cast(value, _opts)  do
        try do
            {:ok, String.Chars.to_string(value)}
        rescue 
            Protocol.UndefinedError ->
              {:error, ["invalid string"]}
        end
    end

    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end
