defmodule Blueprint.Registry do

    alias Blueprint.Types
    alias Blueprint.Validators

    @types [
        any: Types.Any,
        map: Types.Map,
        enum: Types.Enum,
        atom: Types.Atom,
        uuid: Types.UUID,
        tuple: Types.Tuple,
        float: Types.Float,
        array: Types.Array,
        struct: Types.Struct,
        number: Types.Number,
        string: Types.String,
        boolean: Types.Boolean,
        integer: Types.Integer,
        datetime: Types.Datetime,
    ]

    @validators [
        inclusion: Validators.Inclusion,
        exclusion: Validators.Exclusion,
        required: Validators.Required,
        length: Validators.Length,
        format: Validators.Format,
        number: Validators.Number,
        fields: Validators.Fields,
        struct: Validators.Struct,
        uuid: Validators.UUID,
        type: Validators.Type,
        by: Validators.By,
        tld: Validators.Tdl,
        pattern: Validators.Pattern,
    ]


    def type(name) do
        if Keyword.has_key?(@types, name) do
            Keyword.get(@types, name)
        else
            name
        end
    end

    def validator(name) when is_atom(name) do
        Keyword.get(@validators, name)
    end

end
