defmodule Blueprint do
    @moduledoc """
    Data Validation for Elixir.
    """

    alias Blueprint.{
        Extract,
        InvalidValidatorError,
        Validator,
        Validator.Source
    }

    def valid?(data) do
        valid?(data, Extract.settings(data))
    end

    def valid?(data, settings) do
        errors(data, settings) == []
    end

    def validate(data) do
        validate(data, Extract.settings(data))
    end

    def validate(data, settings) do
        case errors(data, settings) do
            errors when errors != [] -> {:error, errors}
            _ -> {:ok, data}
        end
    end

    def errors(data) do
        errors(data, Extract.settings(data))
    end

    def errors(data, settings) do
        Enum.filter(results(data, settings), &match?({:error, _, _, _}, &1))
    end

    def results(data) do
        results(data, Extract.settings(data))
    end

    def results(data, settings) do
        settings
        |> Enum.map(fn {attribute, validations} ->
            validations =
                case validations do
                    rules when is_function(rules) ->
                        [by: validations]

                    rules when is_atom(rules) ->
                        [struct: rules]

                    rules when is_map(rules) ->
                        [map: rules]

                    _ ->
                        validations
                end

            {presence_rules, other_rules} =
                Enum.reduce(validations, {[], []}, fn {name, opts}, {pre_r, other_r} ->
                    if name in [:presence, :absence] do
                        {pre_r ++ [{name, opts}], other_r}
                    else
                        {pre_r, other_r ++ [{name, opts}]}
                    end
                end)

            case presence_rules do
                [] ->
                    Enum.map(validations, fn {name, options} ->
                        result(data, attribute, name, options)
                    end)

                _ ->
                    errors =
                        Enum.map(presence_rules, fn {name, options} ->
                            result(data, attribute, name, options)
                        end)

                    if Enum.find(errors, &(elem(&1, 0) in [:error, :not_applicable])) do
                        errors
                    else
                        Enum.map(other_rules, fn {name, options} ->
                            result(data, attribute, name, options)
                        end)
                    end
            end

        end)
        |> List.flatten()
    end

    defp result(data, attribute, name, options) do
        v = validator(name)

        if Validator.validate?(data, options) do
            result =
                data
                |> extract(attribute, name)
                |> v.validate(data, options)

            case result do
                {:error, message} ->
                    {:error, attribute, name, message}

                :ok ->
                    {:ok, attribute, name}

                _ ->
                    raise "'#{name}'' validator should return :ok or {:error, message}"
            end
        else
            {:not_applicable, attribute, name}
        end
    end

    @doc """
    Lookup a validator from configured sources

    ## Examples

        iex> Blueprint.validator(:presence)
        Blueprint.Validators.Presence

        iex> Blueprint.validator(:exclusion)
        Blueprint.Validators.Exclusion
    """
    def validator(name) do
        case name |> validator(sources()) do
            nil ->
                raise InvalidValidatorError, validator: name, sources: sources()

            found ->
                found
        end
    end

    @doc """
    Lookup a validator from given sources

    ## Examples

        iex> Blueprint.validator(:presence, [[presence: :presence_stub]])
        :presence_stub

        iex> Blueprint.validator(:exclusion, [Blueprint.Validators])
        Blueprint.Validators.Exclusion

        iex> Blueprint.validator(:presence, [Blueprint.Validators, [presence: :presence_stub]])
        Blueprint.Validators.Presence

        iex> Blueprint.validator(:presence, [[presence: :presence_stub], Blueprint.Validators])
        :presence_stub
    """
    def validator(name, sources) do
        Enum.find_value(sources, fn source ->
            Source.lookup(source, name)
        end)
    end

    defp sources do
        case Application.get_env(:blueprint, :sources) do
            nil -> [Blueprint.Validators]
            sources -> sources
        end
    end

    defp extract(data, attribute, :confirmation) do
        [attribute, String.to_atom("#{attribute}_confirmation")]
        |> Enum.map(fn attr -> Extract.attribute(data, attr) end)
    end

    defp extract(data, attribute, _name) do
        Extract.attribute(data, attribute)
    end
end
