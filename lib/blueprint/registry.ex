defmodule Blueprint.Registry do

    alias Blueprint.Type
    alias Blueprint.Validator

    @types [
        any: Type.Any,
        map: Type.Map,
        enum: Type.Enum,
        atom: Type.Atom,
        list: Type.List,
        uuid: Type.UUID,
        tuple: Type.Tuple,
        float: Type.Float,
        struct: Type.Struct,
        number: Type.Number,
        string: Type.String,
        boolean: Type.Boolean,
        integer: Type.Integer,
        datetime: Type.Datetime,
    ]

    @validators [
        inclusion: Validator.Inclusion,
        exclusion: Validator.Exclusion,
        required: Validator.Required,
        length: Validator.Length,
        format: Validator.Format,
        number: Validator.Number,
        fields: Validator.Fields,
        struct: Validator.Struct,
        uuid: Validator.UUID,
        type: Validator.Type,
        by: Validator.By,
        tld: Validator.Tld,
        pattern: Validator.Pattern,
    ]

    def types do
        custom_types = Application.get_env(:types, Blueprint, [])
        Keyword.merge(@types, custom_types)
    end

    def type(name) do
        with {:ok, type} <- Keyword.fetch(types(), name) do
            type
        else
            _ ->
              name_is_type? =
                function_exported?(name, :cast, 2) and function_exported?(name, :dump, 2)

              if name_is_type? do
                  name
              else
                  message = "#{inspect(name)} is not a valid blueprint type"
                  raise RuntimeError, message: message
              end
        end
    end

    def validator(name) when is_atom(name) do
        custom_validators = Application.get_env(:validators, Blueprint, [])
        @validators
        |> Keyword.merge(custom_validators)
        |> Keyword.get(name)
    end

end
