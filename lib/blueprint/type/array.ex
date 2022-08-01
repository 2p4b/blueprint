defmodule Blueprint.Type.Array do

    def cast(nil, _opts) do
        {:ok, nil}
    end

    def cast(value, type) when is_list(value) and is_atom(type) do
        cast(value, type: type)
    end

    def cast(value, opts) when is_list(value) and is_list(opts) do
        {:ok, type} = Keyword.fetch(opts, :type)

        {typename, typeopts} =
            case type do
                {typename, typeopts} ->
                    {typename, typeopts}

                typename when is_atom(typename) ->
                    {typename, []}
            end

        Blueprint.Registry.type(typename) 
        |> cast_values(value, typeopts)
    end

    def cast(_value, _opts) do
        {:error, ["invalid list"]}
    end

    defp cast_values(type, values, opts) do
        values
        |> Enum.with_index()
        |> Enum.reduce({:ok, []}, fn {value, index}, acc -> 
            case acc do 
                {:ok, values} ->
                      case type.cast(value, opts) do
                          {:ok, valid_value} ->
                              {:ok, values ++ [valid_value]}

                          {:error, reason} ->
                              {:error, [{index, reason}]}
                      end

                error ->
                      error
            end
        end)
    end

    def dump(val, opts \\ [])
    def dump(nil, _opts) do
        {:ok, nil}
    end
    def dump(values, opts) do
        case Keyword.fetch(opts, :type) do
            {:ok, {typename, typeopts}} when is_atom(typename) ->
                type = Blueprint.Registry.type(typename)
                values
                |> Enum.with_index()
                |> Enum.reduce_while({:ok, []}, fn {val, index}, acc -> 
                    {:ok, dumped} = acc
                    case type.dump(val, typeopts) do
                        {:ok, val} ->
                              {:cont, {:ok, dumped ++ [val]}}

                        {:error, value} ->
                              {:halt, {:error, [{index, value}]}}
                    end
                end)

            _ ->
              {:ok, values}
        end
    end

end



