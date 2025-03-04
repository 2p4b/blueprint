defmodule Draft.Type.Any do
    
    @behaviour Draft.Type.Behaviour
    
    @impl Draft.Type.Behaviour
    def cast(value, _opts \\ []) do
        {:ok, value}
    end

    @impl Draft.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end

