defmodule Blueprint.Validator do
    @moduledoc """
    Common validator behavior.
    """

    defmodule Behaviour do
        @moduledoc false

        @callback validate(data :: any, options :: any) :: atom | {atom, String.t()}
        @callback validate(data :: any, context :: any, options :: any) :: atom | {atom, String.t()}
    end

    defmodule ErrorMessage do
        @moduledoc false

        defmacro __using__(_) do
            quote do
                @message_fields []
                @before_compile unquote(__MODULE__)
                import unquote(__MODULE__)
            end
        end

        defmacro __before_compile__(_) do
            quote do
                def __validator__(:message_fields), do: @message_fields
            end
        end

        def message(options, default, context \\ []) do
            renderer = extract_error_renderer(options)
            renderer.message(options, default, context)
        end

        defp extract_error_renderer(options) do
            cond do
                Keyword.keyword?(options) && Keyword.has_key?(options, :error_renderer) ->
                    options[:error_renderer]

                renderer = Application.get_env(:blueprint, :error_renderer) ->
                    renderer

                true ->
                    Blueprint.ErrorRenderers.EEx
            end
        end
    end

    defmodule Skipping do
        @moduledoc false

        @doc """
        Checks for allowing blank/nil values, skipping validations.
        """
        defmacro unless_skipping(value, options, do: unskipped) do
            quote do
                if skip?(unquote(value), unquote(options)) do
                    :ok
                else
                    unquote(unskipped)
                end
            end
        end

        def skip?(value, options) do
            cond do
                Keyword.get(options, :allow_blank) -> Blueprint.Blank.blank?(value)
                Keyword.get(options, :allow_nil) -> value == nil
                true -> false
            end
        end
    end


    defmacro __using__(_) do
        quote do
            @behaviour Blueprint.Validator.Behaviour
            import Blueprint.Validator.Skipping
            use Blueprint.Validator.ErrorMessage

            def validate(data, _context, options) do
                validate(data, options)
            end

            defoverridable validate: 3
        end
    end

    def validate?(data, options) when is_list(options) do
        cond do
            Keyword.has_key?(options, :if) ->
                validate_if(data, Keyword.get(options, :if), :all)

            Keyword.has_key?(options, :if_any) ->
                validate_if(data, Keyword.get(options, :if_any), :any)

            Keyword.has_key?(options, :unless) ->
                !validate_if(data, Keyword.get(options, :unless), :all)

            Keyword.has_key?(options, :unless_any) ->
                !validate_if(data, Keyword.get(options, :unless_any), :any)

            true ->
                true
        end
    end

    def validate?(_data, _options), do: true

    defp validate_if(data, conditions, opt) when is_list(conditions) do
        case opt do
            :all -> Enum.all?(conditions, &do_validate_if_condition(data, &1))
            :any -> Enum.any?(conditions, &do_validate_if_condition(data, &1))
        end
    end

    defp validate_if(data, condition, _opt) when is_atom(condition) do
        do_validate_if_condition(data, condition)
    end

    defp validate_if(data, condition, _opt) when is_function(condition) do
        !!condition.(data)
    end

    defp do_validate_if_condition(data, {name, value}) when is_atom(name) do
        Blueprint.Extract.attribute(data, name) == value
    end

    defp do_validate_if_condition(data, condition) when is_atom(condition) do
        !Blueprint.Blank.blank?(Blueprint.Extract.attribute(data, condition))
    end
end
