defmodule Blueprint.Struct do

    defmacro __using__(_) do
        quote do
            import Blueprint.Struct, only: [schema: 1, schema: 2]
        end
    end

    defmacro schema(opts\\[], do: block) do
        quote do
            Blueprint.Struct.__define__(
                unquote(Macro.escape(block)),
                unquote(opts)
            )
        end
    end

    # Most of code here is sourced from typed_struct lib
    defmacro __define__(block, opts) do
        quote do
            Module.register_attribute(__MODULE__, :bp_keys, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_rules, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_types, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_typed, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_fields, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_schema, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_enforce_keys, accumulate: true)
            Module.put_attribute(__MODULE__, :bp_enforce?, unquote(!!opts[:required]))


            # Create a scope to avoid leaks.
            (fn ->
                import Blueprint.Struct
                Module.eval_quoted(__ENV__, unquote(block))
            end).()

            @enforce_keys @bp_enforce_keys
            defstruct @bp_fields

            require Blueprint.Extract.Struct
            Blueprint.Extract.Struct.for_struct(@bp_rules)

            Blueprint.Struct.__type__(@bp_types, unquote(opts))

            Blueprint.Struct.__contructor__(@bp_keys)

            Module.delete_attribute(__MODULE__, :bp_enforce_keys)
            Module.delete_attribute(__MODULE__, :bp_enforce?)
            Module.delete_attribute(__MODULE__, :bp_fields)
            Module.delete_attribute(__MODULE__, :bp_rules)
            Module.delete_attribute(__MODULE__, :bp_types)
            Module.delete_attribute(__MODULE__, :bp_keys)
        end
    end

    defmacro __contructor__(bp_keys) do
        quote do
            Module.register_attribute(__MODULE__, :bp_str_keys, accumulate: true)

            Enum.each(unquote(bp_keys), fn key ->
                Module.put_attribute(__MODULE__, :bp_str_keys, {key, to_string(key)})
            end)

            def new(attr \\ %{})
            def new(attr) when is_map(attr) do
                result =
                    Enum.reduce(@bp_str_keys, %{}, fn ({akey, skey}, acc) ->
                        cond do
                            Map.has_key?(attr, akey) ->
                                Map.put(acc, akey, Map.get(attr, akey))

                            Map.has_key?(attr, skey) ->
                                Map.put(acc, akey, Map.get(attr, skey))

                            true ->
                                acc
                        end
                    end)
                    |> cast([])

                case result do
                    {:ok, data} ->
                        data

                    {:error, error} ->
                        raise ArgumentError, message: inspect(error)
                end
            end


            def new(attr) when is_list(attr) do
                Kernel.apply(__MODULE__, :new, [Enum.into(attr, %{})])
            end

            def from_struct(strt, remap \\ []) when is_struct(strt) do
                params =
                    Enum.reduce(remap, Map.from_struct(strt), fn({nkey, okey}, acc) ->
                        with {:ok, value} <- Map.fetch(acc, okey) do
                            Map.put(acc, nkey, value)
                        else
                            _ -> acc
                        end
                    end)
                Kernel.apply(__MODULE__, :new, [params])
            end

            def cast(attr, opts \\ [])
            def cast(nil, opts) do
                {:ok, nil}
            end
            def cast(attr, opts) do
                __cast__(attr, opts)
            end


            def dump(attr, opts \\ [])
            def dump(nil, _opts) do
                {:ok, nil}
            end
            def dump(%__MODULE__{}=attr, opts) do
                __dump__(attr, opts)
            end

            def __fields__() do
                @bp_schema
            end

            def __dump__(data, opts \\ []) do
                Blueprint.Type.Map.dump(data, fields: __fields__())
            end

            def __cast__(attr, opts) when is_list(attr) do
                attr
                |> Enum.into(%{})
                |> __cast__(opts)
            end

            def __cast__(attr, _opts) when is_map(attr) do
                case Blueprint.Type.Map.cast(attr, fields: __fields__()) do
                    {:ok, data} ->
                        {:ok, struct(__MODULE__, data)}

                    error ->
                        error
                end
            end

            Module.delete_attribute(__MODULE__, :bp_keys_str)
        end
    end

    defmacro __type__(types, opts) do
        if Keyword.get(opts, :opaque, false) do
            quote bind_quoted: [types: types] do
                @opaque t() :: %__MODULE__{unquote_splicing(types)}
            end
        else
            quote bind_quoted: [types: types] do
                @type t() :: %__MODULE__{unquote_splicing(types)}
            end
        end
    end

    defmacro field(name, type, opts \\ []) do
        quote do
            Blueprint.Struct.__field__(
                __MODULE__,
                unquote(name),
                unquote(type),
                unquote(opts)
            )
        end
    end

    @doc false
    def __field__(mod, name, type, opts) when is_atom(name) do
        if mod |> Module.get_attribute(:bp_fields) |> Keyword.has_key?(name) do
            raise ArgumentError, "the field #{inspect(name)} is already set"
        end

        has_default? = Keyword.has_key?(opts, :default)
        enforce_by_default? = Module.get_attribute(mod, :bp_enforce?)

        enforce? =
            if is_nil(opts[:required]) do
                enforce_by_default? && !has_default?
            else
                !!opts[:required]
            end

        default_is_nil? = 
            if has_default? do
                Keyword.get(opts, :default) === nil
            else
                false
            end


        nullable? = 
            if has_default? and default_is_nil? do
                true
            else
                !has_default? && !enforce?
            end


        rules  = rules_for(type, opts)

        Module.put_attribute(mod, :bp_schema, {name, {type, rules}})

        Module.put_attribute(mod, :bp_keys, name)
        Module.put_attribute(mod, :bp_rules, {name, clean_rules(rules, nullable?)})
        Module.put_attribute(mod, :bp_fields, {name, opts[:default]})
        Module.put_attribute(mod, :bp_types, {name, type_for(type, nullable?)})

        if enforce? do
            Module.put_attribute(mod, :bp_enforce_keys, name)
        end

    end

    def __field__(_mod, name, _type, _opts) do
        raise ArgumentError, "a field name must be an atom, got #{inspect(name)}"
    end

    # Makes the type nullable if the key is not enforced.
    defp type_for(type, false), do: type

    defp type_for(type, _), do: quote(do: unquote(type) | nil)

    defp rules_for({:map, typeopts}, opts) do
        typeopts
        |> Enum.map(fn 
            {type, []} -> {type, []}
            {type, [_| valopts]} -> {type, valopts}
        end) 
        |> Enum.concat(opts)
    end

    defp rules_for(_, opts), do: opts

    defp clean_rules(opts, nullable) when is_list(opts) do
        opts
        |> Keyword.delete(:default)
        |> Keyword.delete(:required) 
        |> Keyword.delete(:nullable)
        |> Keyword.put(:required, !nullable)
    end

    defp clean_rules(opts, _nullable) do
        opts
    end
end
