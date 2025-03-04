defprotocol Draft.Extract do
    @doc "Extract the validation settings"
    def rules(data)

    @doc "Extract an attribute's value"
    def attribute(data, name)
end

defmodule Draft.Extract.Schema do
    defmacro for_struct(opts) do
        quote do
            with opts <- unquote(opts) do
                defimpl Draft.Extract, for: __MODULE__ do
                    @bp_mod opts
                    def rules(_mod) do
                        @bp_mod
                    end

                    def attribute(map, [root_attr | path]) do
                        map |> Map.get(root_attr) |> get_in(path)
                    end

                    def attribute(map, name) do
                        Map.get(map, name)
                    end
                end
            end
        end
    end
end

