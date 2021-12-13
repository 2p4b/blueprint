defmodule Blueprint.Struct do

    defmacro __using__(_) do
        quote do
            import Blueprint.Struct, only: [blueprint: 1, blueprint: 2]
        end
    end

    defmacro blueprint(opts\\[], do: block) do
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
            Module.register_attribute(__MODULE__, :bp_rules, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_keys, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_types, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_typed, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_fields, accumulate: true)
            Module.register_attribute(__MODULE__, :bp_enforce_keys, accumulate: true)
            Module.put_attribute(__MODULE__, :bp_enforce?, unquote(!!opts[:required]))


            # Create a scope to avoid leaks.
            (fn ->
                import Blueprint.Struct
                Module.eval_quoted(__ENV__, unquote(block))
            end).()

            @enforce_keys @bp_enforce_keys
            defstruct @bp_fields

            #IO.inspect(@bp_rules)
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
                params =
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

                struct!(__MODULE__, params)
            end

            def new(attr) when is_list(attr) do
                # Let elixir handle it!
                struct(__MODULE__, attr)
            end

            def from(strt, remap\\[]) when is_struct(strt) do
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
                unquote(Macro.escape(type)),
                unquote(opts)
            )
        end
    end

    @doc false
    def __field__(mod, name, type, opts)
    when is_atom(name) and is_atom(opts) and type in [:struct] do
        if mod |> Module.get_attribute(:bp_fields) |> Keyword.has_key?(name) do
            raise ArgumentError, "the field #{inspect(name)} is already set"
        end

        has_default? = false
        enforce_by_default? = Module.get_attribute(mod, :bp_enforce?)

        nullable? = enforce_by_default? && !has_default?

        Module.put_attribute(mod, :bp_keys, name)
        Module.put_attribute(mod, :bp_rules, {name, [struct: clean_rules(opts)]})
        Module.put_attribute(mod, :bp_fields, {name, nil})
        Module.put_attribute(mod, :bp_types, {name, type_for(type, nullable?)})

        if enforce_by_default? do
            Module.put_attribute(mod, :bp_enforce_keys, name)
        end

    end

    @doc false
    def __field__(mod, name, type, opts)
    when is_atom(name) and is_map(opts) and type in [:map, :struct] do
        if mod |> Module.get_attribute(:bp_fields) |> Keyword.has_key?(name) do
            raise ArgumentError, "the field #{inspect(name)} is already set"
        end

        has_default? = false
        enforce_by_default? = Module.get_attribute(mod, :bp_enforce?)

        nullable? = enforce_by_default? && !has_default?

        Module.put_attribute(mod, :bp_keys, name)
        Module.put_attribute(mod, :bp_rules, {name, [map: clean_rules(opts)]})
        Module.put_attribute(mod, :bp_fields, {name, nil})
        Module.put_attribute(mod, :bp_types, {name, type_for(type, nullable?)})

        if enforce_by_default? do
            Module.put_attribute(mod, :bp_enforce_keys, name)
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

        nullable? = !has_default? && !enforce?

        rules  = rules_for(type, opts)

        Module.put_attribute(mod, :bp_keys, name)
        Module.put_attribute(mod, :bp_rules, {name, clean_rules(rules)})
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

    defp rules_for(:string, opts), do: opts

    defp rules_for(:number, rules) do
        valid_rules = [
            :equal_to,
            :less_than,
            :greater_than,
            :greater_than_or_equal_to,
            :less_than_or_equal_to,
        ]
        extract_rules(:number, valid_rules, rules)
    end

    defp rules_for(:uuid, rules) do
        valid_rules = [:format]
        [uuid: true] ++ extract_rules(:uuid, valid_rules, rules)
    end

    defp rules_for(:map, rules) do
        rules
    end

    defp rules_for(:struct, rules) do
        rules
    end

    defp rules_for(:boolean, rules) do
        [boolean: true] ++ rules
    end

    defp extract_rules(type, valid_rules, opts) do
        {extracted_rules, other_rules} = partion_rules(valid_rules, opts)
        [{type, extracted_rules}] ++ other_rules
    end

    defp partion_rules(valid_rules, global_rules) do
        Enum.reduce(global_rules, {[], []}, fn {rule, ropts}, {rules, validators} ->
            if rule in valid_rules do
                {rules ++ [{rule, ropts}], validators}
            else
                {rules, validators ++ [{rule, ropts}] }
            end
        end)
    end

    defp clean_rules(opts) when is_list(opts) do
        opts
        |> Keyword.delete(:default)
    end

    defp clean_rules(opts) do
        opts
    end
end
