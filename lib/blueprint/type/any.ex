defmodule Blueprint.Type.Any do
    
    @behaviour Blueprint.Type.Behaviour
    
    @impl Blueprint.Type.Behaviour
    def cast(value, _opts \\ []) do
        {:ok, value}
    end

    @impl Blueprint.Type.Behaviour
    def dump(value, _opts \\ []) do
        {:ok, value}
    end

end

