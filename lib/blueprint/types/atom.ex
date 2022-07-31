defmodule Blueprint.Types.Atom do

    def cast(value, _opts) when is_atom(value) do
        {:ok, value}
    end

    def cast(value, _opts) when is_binary(value) do
        try do
            {:ok, String.to_existing_atom(value)}
        rescue 
            ArgumentError ->
              {:error, ["string atom value not found"]}
        end
    end

    def cast(_value, _opts) do
        {:error, ["invalid atom"]}
    end

end

