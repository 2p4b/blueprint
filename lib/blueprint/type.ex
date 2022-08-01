defmodule Blueprint.Type do
    defmodule Behaviour do
        @moduledoc false
        @callback cast(data :: any, options :: any) :: {atom, term()}
        @callback dump(data :: any, options :: any) :: {atom, term()}
    end
end
