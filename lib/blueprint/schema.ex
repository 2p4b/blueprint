defmodule Blueprint.Schema do

    defmacro __using__(_) do
        quote do
            import Blueprint.Schema, only: [schema: 1, schema: 2]
        end
    end

    defmacro schema(do: block) do
        opts = []
        quote do
            Blueprint.Schema.__define__(
                unquote(Macro.escape(block)),
                unquote(opts)
            )
        end
    end

    defmacro schema(opts) when is_list(opts) do
        block = {:__block__, [], []}
        quote do
            Blueprint.Schema.__define__(
                unquote(Macro.escape(block)),
                unquote(opts)
            )
        end
    end

    defmacro schema(opts, do: block) when is_list(opts) do
        quote do
            Blueprint.Schema.__define__(
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
            Module.register_attribute(__MODULE__, :bp_typed, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_specs, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_fields, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_schema, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_enforce_keys, accumulate: true)
            Module.put_attribute(__MODULE__, :bp_enforce?, unquote(!!opts[:required]))

            Module.put_attribute(__MODULE__, :bp_bases, unquote(opts) |> Keyword.get(:extends, []) |> List.wrap())

            Enum.each(@bp_bases, fn base -> 
                base
                |> Kernel.apply(:__blueprint__, [])
                |> Enum.each(fn {name, {type, opts, mod}} -> 
                    Blueprint.Schema.__field__(__MODULE__, name, type, opts, mod, true)
                end)
            end)

            # Create a scope to avoid leaks.
            (fn ->
                import Blueprint.Schema, only: [field: 2, field: 3]
                Module.eval_quoted(__ENV__, unquote(block))
            end).()

            @enforce_keys @bp_enforce_keys
            defstruct @bp_fields

            require Blueprint.Extract.Schema
            Blueprint.Extract.Schema.for_struct(@bp_rules)
            Blueprint.Schema.__type__(@bp_specs)

            Blueprint.Schema.__contructor__(@bp_keys)

            Module.delete_attribute(__MODULE__, :bp_enforce_keys)
            Module.delete_attribute(__MODULE__, :bp_enforce?)
            Module.delete_attribute(__MODULE__, :bp_fields)
            Module.delete_attribute(__MODULE__, :bp_rules)
            Module.delete_attribute(__MODULE__, :bp_specs)
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
                case cast(attr, []) do
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

            def __blueprint__() do
                @bp_schema
            end

            def __dump__(data, opts \\ []) do
                Blueprint.Type.Map.dump(data, fields: __fields__())
            end

            def __fields__ do
                __blueprint__()
                |> Enum.map(fn {name, {type, opts, _info}} -> {name, {type, opts}} end)
            end

            def __cast__(attr, opts) when is_list(attr) do
                attr
                |> Enum.into(%{})
                |> __cast__(opts)
            end

            def __cast__(attr, _opts) when is_map(attr) do
                attr =
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

    defmacro __type__(types) do
        quote bind_quoted: [types: types] do
            @type t() :: %__MODULE__{unquote_splicing(types)}
        end
    end

    defmacro field(name, type, opts \\ []) do
        quote do
            Blueprint.Schema.__field__(
                __MODULE__,
                unquote(name),
                unquote(type),
                unquote(opts),
                __MODULE__,
                false
            )
        end
    end

    @doc false
    def __field__(mod, name, type, opts, dmod, overwrite) when is_atom(name) do

        if overwrite do
            if Module.get_attribute(mod, :bp_schema) |> Keyword.get(name) do
                # overwite inheritance field
                __undefine__(mod, name)
            end
        else
            if fdef = Module.get_attribute(mod, :bp_schema) |> Keyword.get(name) do
                defpath = elem(fdef, 2)
                inheritance_path =
                      defpath
                      |> Enum.map(&Kernel.inspect/1)
                      |> Enum.join(" > ")

                if  !!opts[:overwrite] and List.wrap(mod) !== defpath do
                    __undefine__(mod, name)
                else
                    message = """
                    duplicate field #{inspect(name)} 
                    already defined in #{inheritance_path}
                    """
                    raise KeyError, message
                end
            end
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

        opts = 
            if enforce? and not(has_default?) do
                Keyword.put(opts, :required, :true)
            else
                opts
            end
            |> clean_opts()

        defpath = 
            if mod === dmod do 
                List.wrap(mod) 
            else
                List.wrap(mod) ++ List.wrap(dmod)
            end

        spec = 
            case Keyword.fetch(opts, :spec) do
                {:ok, spec} ->
                    if nullable? do
                        quote(do: unquote(spec)() | nil)
                    else
                        quote(do: unquote(spec)())
                    end
                _ ->
                    registered_types = Blueprint.Registry.types()
                    with {:ok, def_type} <- Keyword.fetch(registered_types, type) do
                        def_type
                    else
                        _ ->
                           type
                    end
                    |> type_spec(nullable?)
            end

        Module.put_attribute(mod, :bp_keys, name)
        Module.put_attribute(mod, :bp_rules, {name, opts})
        Module.put_attribute(mod, :bp_specs, {name, spec})
        Module.put_attribute(mod, :bp_fields, {name, opts[:default]})
        Module.put_attribute(mod, :bp_schema, {name, {type, opts, defpath}})
        if enforce? do
            Module.put_attribute(mod, :bp_enforce_keys, name)
        end
    end

    def __undefine__(mod, name) do
        delete_attribute_key(mod, :bp_schema, name)
        delete_attribute_key(mod, :bp_fields, name)
        delete_attribute_key(mod, :bp_rules, name)
        delete_attribute_key(mod, :bp_specs, name)

        remove_attribute_value(mod, :bp_keys, name)
        remove_attribute_value(mod, :bp_enforece_keys, name)
    end

    def delete_attribute_key(mod, attribute, key) do
        values = Module.get_attribute(mod, attribute, []) |> Keyword.delete(key)
        reset_attribute_values(mod, attribute, values)
    end

    def remove_attribute_value(mod, attribute, key) do
        values = Module.get_attribute(mod, attribute, []) -- List.wrap(key)
        reset_attribute_values(mod, attribute, values)
    end

    def reset_attribute_values(mod, attribute, values) do
        Module.delete_attribute(mod, attribute)
        Module.register_attribute(mod, attribute, accumulate: true)
        Enum.each(values, fn value -> 
            Module.put_attribute(mod, attribute, value)
        end)
    end

    def __field__(_mod, name, _type, _opts) do
        raise ArgumentError, "a field name must be an atom, got #{inspect(name)}"
    end

    # Makes the type nullable if the key is not enforced.
    defp type_spec(type, false), do: quote(do: unquote(type).t())

    defp type_spec(type, _), do: quote(do: unquote(type).t() | nil)

    defp clean_opts(opts) when is_list(opts) do
        opts
        |> Keyword.delete(:nullable)
        |> Keyword.delete(:overwrite) 
    end

end
