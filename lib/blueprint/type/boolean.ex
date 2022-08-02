defmodule Blueprint.Type.Boolean do

    @truth [true, 1, "1", "true"]

    @falsly [false, 0, "0", "false"]

    @behaviour Blueprint.Type.Behaviour
    
    @impl Blueprint.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when value in @truth do
        {:ok, true}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, _opts) when value in @falsly do
        {:ok, false}
    end

    @impl Blueprint.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid boolean"]}
    end

    @impl Blueprint.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end
