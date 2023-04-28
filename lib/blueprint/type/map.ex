defmodule Blueprint.Type.Map do

    @behaviour Blueprint.Type.Behaviour
    
    @impl Blueprint.Type.Behaviour
    def cast(nil, _opts) do
        {:ok, nil}
    end

    @impl Blueprint.Type.Behaviour
    def cast(value, fields) when is_map(value) and is_list(fields) do
        cast(value, Enum.into(fields, %{}))
    end

    @impl Blueprint.Type.Behaviour
    def cast(data, %{fields: fields}=opts) when is_list(fields) do
        cast(data, %{opts | fields: Enum.into(fields, %{})})
    end

    @impl Blueprint.Type.Behaviour
    def cast(data, %{fields: fields}) when is_map(data) and is_map(fields) do
        Map.keys(fields)
        |> Enum.reduce({:ok, %{}}, fn key, acc -> 

            {value_type, opts} = 
                case Map.get(fields, key) do
                    {type, opts} when is_atom(type) and is_list(opts) ->
                            {type, opts}

                    [type | opts] when is_atom(type) and is_list(opts) ->
                            {type, opts}

                    type when is_atom(type) ->
                            {type, []}
                end

            case get_value(data, key, opts) do
                {:ok, value} ->

                    type = Blueprint.Registry.type(value_type) 

                    case acc do 
                        {:ok, values} ->
                            case type.cast(value, opts) do
                                {:ok, valid_value} ->
                                    {:ok, Map.put(values, key, valid_value)}

                                {:error, reason} ->
                                    {:error, [{key, reason}]}
                            end

                        {:error, errors} ->
                            case type.cast(value, opts) do
                                {:error, reason} ->
                                    {:error, errors ++ [{key, reason}]}

                                _ ->
                                    acc
                            end
                    end

                _not_found ->
                    acc
            end
        end)
    end

    @impl Blueprint.Type.Behaviour
    def cast(data, _opts) when is_map(data) do
        {:ok, data}
    end

    @impl Blueprint.Type.Behaviour
    def cast(_value, _opts) do
        {:error, ["invalid map"]}
    end

    def get_value(data, key, opts) when is_map(data) and is_atom(key) do
        string_key = Atom.to_string(key) 
        cond do
            Map.has_key?(data, key) ->
                Map.fetch(data, key)

            Map.has_key?(data, string_key) ->
                Map.fetch(data, string_key)

            Keyword.has_key?(opts, :default) ->
                Keyword.fetch(opts, :default)

            true ->
                {:error, :key}
        end
    end

    def get_value(data, key, opts) when is_map(data) and is_binary(key) do
        if Map.has_key?(data, key) do
            Map.fetch(data, key)
        else
            try do
                atom_key = String.to_existing_atom(key)
                Map.fetch(data, atom_key)
            rescue 
                ArgumentError ->
                    if Keyword.has_key?(opts, :default) do
                        Keyword.fetch(opts, :default)
                    else
                          {:error, :key}
                    end
            end
        end
    end

    @impl Blueprint.Type.Behaviour
    def dump(values, opts \\ []) 
    def dump(nil, _opts) do
        {:ok, nil}
    end

    @impl Blueprint.Type.Behaviour
    def dump(values, opts) do

        case Keyword.fetch(opts, :fields) do
            {:ok, fields} ->
                fields
                |> Enum.reduce_while({:ok, %{}}, fn {key, typeinfo}, acc -> 
                    {typename, typeopts} =
                        case typeinfo do
                            {typename, typeopts} ->
                                  {typename, typeopts}

                            [typename | typeopts] when is_atom(typename) ->
                                  {typename, typeopts}

                            typename when is_atom(typename) ->
                                  {typename, []}
                        end

                    value = 
                        case get_value(values, key, typeopts) do
                            {:ok, value} ->
                                  value
                            {:error, :key} ->
                                  nil
                        end
                    type = Blueprint.Registry.type(typename)
                    case type.dump(value, typeopts) do
                        {:ok, val} ->
                              {:ok, data} = acc
                              keyname = String.Chars.to_string(key)
                              {:cont, {:ok, Map.put(data, keyname, val)}}

                        {:error, value} ->
                              {:halt, {:error, [{key, value}]}}
                    end
                end)

            _ ->
              {:ok, values}
        end
    end

end
