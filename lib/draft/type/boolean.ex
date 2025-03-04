defmodule Draft.Type.Boolean do

    @truth [true, 1, "1", "true"]

    @falsly [false, 0, "0", "false"]

    @behaviour Draft.Type.Behaviour
    
    @impl Draft.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Draft.Type.Behaviour
    def cast(value, _opts) when value in @truth do
        {:ok, true}
    end

    @impl Draft.Type.Behaviour
    def cast(value, _opts) when value in @falsly do
        {:ok, false}
    end

    @impl Draft.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid boolean"]}
    end

    @impl Draft.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end
