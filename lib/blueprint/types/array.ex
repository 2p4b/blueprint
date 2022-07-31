defmodule Blueprint.Types.Array do

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

end



