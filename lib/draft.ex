defmodule Draft do
    @moduledoc """
    Data Validation for Elixir.
    """
    alias Draft.Extract

    def valid?(data) when is_struct(data) do
        valid?(data, Extract.rules(data))
    end

    def valid?(data, settings) do
        errors(data, settings) == []
    end

    def validate(data) when is_struct(data) do
        validate(data, Extract.rules(data))
    end

    def validate(data, settings) do
        case errors(data, settings) do
            errors when errors != [] -> {:error, errors}
            _ -> {:ok, data}
        end
    end

    def errors(data) when is_struct(data) do
        errors(data, Extract.rules(data))
    end

    def errors(data, settings) do
        results(data, settings)
    end

    def results(data) when is_struct(data) do
        results(data, Extract.rules(data))
    end

    def results(data, settings) 
    when not(is_list(data)) and not(is_map(data)) do
        results([value: data], value: settings)
    end

    def results(data, settings) do
        settings
        |> Enum.map(fn {key, rules} ->
            Enum.reduce_while(rules, [], fn rule, _acc -> 
                {name, opts} = 
                    cond do
                        is_tuple(rule) ->
                            rule

                        is_atom(rule) ->
                            {rule, []}

                        true ->
                            message = "rule must be atom or {name, opts} not #{rule}"
                            raise ArgumentError, message: message
                    end

                validator = Draft.Registry.validator(name)

                exists = Map.has_key?(data, key)
                            
                cond do
                    exists and is_atom(validator) and not(is_nil(validator)) ->
                        value = Map.get(data, key)
                        case validator.validate(value, data, opts) do
                            {:ok, _} ->
                                {:cont, []}

                            {:error, error} ->
                                {:halt, [{key, error}]}
                        end

                    true ->
                        {:cont, []}
                end
            end)
        end)
        |> List.flatten()
    end

    def validate_required(attr, required)
    def validate_required(attr, required) when is_list(attr) do
        attr
        |> Enum.into(%{})
        |> validate_required(required)
    end
    def validate_required(attr, required) when is_map(required) do
        validate_required(attr, Map.to_list(required))
    end
    def validate_required(attr, required) when is_map(attr) and is_list(required) do
        notfound =
            Enum.find(required, fn key -> 
                attr
                |> Map.has_key?(key)
                |> Kernel.not()
            end) 
        if is_nil(notfound) do
            {:ok, attr}
        else
            {:error, notfound}
        end
    end

end
