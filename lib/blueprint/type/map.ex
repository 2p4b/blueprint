defmodule Blueprint.Type.Map do

    def cast(nil, _opts) do
        {:ok, nil}
    end

    def cast(value, fields) when is_map(value) and is_list(fields) do
        cast(value, Enum.into(fields, %{}))
    end

    def cast(data, %{fields: fields}=opts) when is_list(fields) do
        cast(data, %{opts | fields: Enum.into(fields, %{})})
    end

    def cast(data, %{fields: fields}) when is_map(data) and is_map(fields) do
        Map.keys(fields)
        |> Enum.reduce({:ok, %{}}, fn key, acc -> 
            case get_value(data, key) do
                {:ok, value} ->
                    {value_type, opts} = 
                        case Map.get(fields, key) do
                            {type, opts} when is_atom(type) ->
                                    {type, opts}

                            [type | opts] when is_atom(type) and is_list(opts) ->
                                    {type, opts}

                            type when is_atom(type) ->
                                    {type, []}
                        end

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

    def cast(data, _opts) when is_map(data) do
        {:ok, data}
    end


    def cast(_value, _opts) do
        {:error, ["invalid map"]}
    end

    def dump(value, _opts \\ []) do
        {:ok, value}
    end

    def get_value(data, key) when is_map(data) and is_atom(key) do
        if Map.has_key?(data, key) do
            Map.fetch(data, key)
        else
            string_key = Atom.to_string(key) 
            Map.fetch(data, string_key)
        end
    end

    def get_value(data, key) when is_map(data) and is_binary(key) do
        if Map.has_key?(data, key) do
            Map.fetch(data, key)
        else
            try do
                atom_key = String.to_existing_atom(key)
                Map.fetch(data, atom_key)
            rescue 
                ArgumentError ->
                    {:error, :key}
            end
        end
    end

    def get_value(data, key) when is_map(data) and is_atom(key) do
        Map.fetch(data, key)
    end

end

