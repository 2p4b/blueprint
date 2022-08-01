defmodule Blueprint.Type.Any do

    def cast(value, _opts \\ []) do
        {:ok, value}
    end

    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end




