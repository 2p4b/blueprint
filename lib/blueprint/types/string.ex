defmodule Blueprint.Types.String do

    def cast([], _opts) do
        {:error, ["invalid string"]}
    end
    def cast(%{}, _opts) do
        {:error, ["invalid string"]}
    end

    def cast(value, _opts)  do
        try do
            {:ok, String.Chars.to_string(value)}
        rescue 
            Protocol.UndefinedError ->
              {:error, ["invalid string"]}
        end
    end

end
