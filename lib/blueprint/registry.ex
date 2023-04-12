defmodule Blueprint.Registry do

    alias Blueprint.Type
    alias Blueprint.Validator

    @types [
        any: Type.Any,
        map: Type.Map,
        enum: Type.Enum,
        atom: Type.Atom,
        uuid: Type.UUID,
        tuple: Type.Tuple,
        float: Type.Float,
        array: Type.Array,
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


    def type(name) do
        custom_types = Application.get_env(:types, Blueprint, [])
        types = Keyword.merge(@types, custom_types)
        if Keyword.has_key?(types, name) do
            Keyword.get(types, name)
        else
            name
        end
    end

    def validator(name) when is_atom(name) do
        custom_validators = Application.get_env(:validators, Blueprint, [])
        @validators
        |> Keyword.merge(custom_validators)
        |> Keyword.get(name)
    end

end
