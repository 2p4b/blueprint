defprotocol Blueprint.Extract do
    @doc "Extract the validation settings"
    def settings(data)

    @doc "Extract an attribute's value"
    def attribute(data, name)
end

defimpl Blueprint.Extract, for: List do
    def settings(data) do
        Keyword.get(data, :_rules)
    end

    def attribute(map, path) when is_list(path) do
        get_in(map, path)
    end

    def attribute(data, name) do
        Keyword.get(data, name)
    end
end

defimpl Blueprint.Extract, for: Map do
    def settings(map) do
        Map.get(map, :__blueprint__)
    end

    def attribute(map, name) do
        Map.get(map, name)
    end
end

defmodule Blueprint.Extract.Struct do
    @moduledoc false
    defmacro for_struct do
        quote do
            defimpl Blueprint.Blank, for: __MODULE__ do
                def blank?(struct), do: struct |> Map.from_struct() |> map_size == 0
            end

            defimpl Blueprint.Extract, for: __MODULE__ do
                def settings(%{__struct__: module}) do
                    module.__blueprint__()
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

    defmacro for_struct(opts) do
        quote do
            with opts <- unquote(opts) do
                defimpl Blueprint.Blank, for: __MODULE__ do
                    def blank?(struct), do: struct |> Map.from_struct() |> map_size == 0
                end

                defimpl Blueprint.Extract, for: __MODULE__ do
                    @bp_mod opts
                    def settings(_mod) do
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

defimpl Blueprint.Extract, for: Tuple do
    def settings(record) do
        [name | _tail] = Tuple.to_list(record)
        record_validations(name)
    end

    def attribute(record, attribute) do
        [name | _tail] = Tuple.to_list(record)

        case record_attribute_index(name, attribute) do
            nil -> nil
            number when is_integer(number) -> elem(record, number)
        end
    end

    defp record_validations(name) do
        name.__record__(:vex_validations)
        rescue
        _ -> []
    end

    defp record_attribute_index(name, attribute) do
        name.__record__(:index, attribute)
        rescue
        _ -> nil
    end
end
