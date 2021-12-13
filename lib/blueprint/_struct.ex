defmodule Blueprint.Structtt do
    @moduledoc false

    defmacro __using__(_) do
        quote do
            Module.register_attribute(__MODULE__, :blueprint, accumulate: true)
            @before_compile unquote(__MODULE__)
            import unquote(__MODULE__)
            def valid?(self), do: Blueprint.valid?(self)
        end
    end

    defmacro __before_compile__(_) do
        quote do
            def __blueprint__(), do: @blueprint

            require Blueprint.Extract.Struct
            Blueprint.Extract.Struct.for_struct()
            Module.delete_attribute(__MODULE__, :blueprint)
        end
    end

    defmacro validates(name, validations \\ []) do
        quote do
            Module.put_attribute(__MODULE__, :blueprint, {unquote(name), unquote(validations)})
        end
    end

end
