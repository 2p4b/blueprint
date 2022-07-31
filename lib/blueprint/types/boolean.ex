defmodule Blueprint.Types.Boolean do

    @truth [true, 1, "1", "true"]

    @falsly [false, 0, "0", "false"]

    def cast(value, _opts) when value in @truth do
        {:ok, true}
    end

    def cast(value, _opts) when value in @falsly do
        {:ok, false}
    end

    def cast(_value, _opts) do
        {:error, ["invalid boolean"]}
    end

end


