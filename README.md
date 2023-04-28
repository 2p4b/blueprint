# Blueprint

<!-- @moduledoc -->

Blueprint is a library for defining structs with types some degree of type checking.
inspired by the Ecto.Schema, only this time schemas can inherite from other schemas

## Usage

### Setup

To use Blueprint in your project, add this to your Mix dependencies:

```elixir
{:blueprint, git: "https://github.com/mfoncho/blueprint.git"}
```


### General usage

To define a Simple blueprint struct

```elixir
defmodule StructType do
    use Blueprint.Struct

    # Define your struct.
    schema do
        #Define a field with type string
        field :name, :string

        field :id,   :uuid

        #Define a field with default value
        field :age,  :number,   default: 10

        field :amount,  :float
    end
end
```

Nested blueprints

```elixir
defmodule Nested do
    use Blueprint.Struct
    schema do
        field :value, :number
    end
end

defmodule Typed do
    use Blueprint.Struct
    schema do
        # Nested field
        field :nested,  Nested,  default: nil
        field :name,    :string,   default: "my name"
    end
end
```

### Inheritance
Blueprint structs can inherit fields from other schema, their types and validation rules, using the `:extends` option
- `:extends`  Blurpint module or list of bluerint Modules for inheriting from muliple bases

#### Inherit from single base
```elixir
defmodule Super do
    use Blueprint.Struct
    schema do
        field :super, :number
    end
end

defmodule Base do
    schema extends: Super do
        field :base, :number
    end
end

defmodule Child do
    use Blueprint.Struct
    schema extends: Base do
        field :child,  :number
    end
end

%Child{super: 1, base: 2, child: 3}
```

#### Inherit from multiple base modules
```elixir
defmodule Super do
    use Blueprint.Struct
    schema do
        field :super, :number
    end
end

defmodule Base do
    use Blueprint.Struct
    schema do
        field :base, :number
    end
end

defmodule Child do
    use Blueprint.Struct
    schema extends: [Base, Super] do
        field :child,  :number
    end
end

%Child{super: 1, base: 2, child: 3}

```

Sometime users may wish to overwrite certain fields with custom rules or type, 
this can be done with the `overwrite` field option

#### overwrite field base definition
```elixir
defmodule Super do
    use Blueprint.Struct
    schema do
        field :super, :number
    end
end

defmodule Base do
    use Blueprint.Struct
    schema do
        field :base, :number
    end
end

defmodule Child do
    use Blueprint.Struct
    schema extends: [Base, Super] do
        field :base, :string, overwrite: true
    end
end

%Child{super: 1, base: "2", child: 3}

```

### Methods

Blueprint defines a constructor `new` method to create
struct from map or list. Note: the new method will throw if 
validation of field type fails

```elixir
data = StructType.new(%{...})
```

Blueprint defines a constructor `cast` method to struct but unlike
the `new` method is returns the usual `{:ok, value}` or `{:error, reason}`

```elixir
{:ok, data} = StructType.cast(%{...})
```

```elixir
{:error, reason} = StructType.cast(123)
```

Blueprint defines a constructor `from_struct` just like `new` but made to look like
the familiar `Map.from_struct` is uses the `new` method and will throw if 
validation fails

```elixir
data = StructType.from_struct(%StructType{...})
```

Blueprint defines a `dump` method to dump the data to simple Map that can be easily 
serializable

```elixir
{:ok, data} = StructType.dump(%StructType{...})
```

## Advanced usage

### Required fields

Defining required fields is simple required fields cannot be `nil`

There are multiple way of going about this

#### Make all fields required

```elixir
defmodule StructType do
    use Blueprint.Struct

    # This will make all fields required.
    schema [required: true] do
        field :id,      :uuid
        field :name,    :string
        field :age,     :number
        field :amount,  :float
    end
end
```

#### Exclude some fields from being required

By making the default value of a field `nil` that field becomes nullable

```elixir
defmodule StructType do
    use Blueprint.Struct

    # This will make all fields required.
    schema [required: true] do
        field :id,      :uuid
        field :name,    :string
        field :age,     :number

        # This field will can by nill
        field :amount,  :float,     default: nil
    end
end
```

#### Make select fields required

By making the default value of a field `nil` that field becomes nullable

```elixir
defmodule StructType do
    use Blueprint.Struct

    # This will make all fields nill by default except id.
    schema do
        # Ensure id is required
        field :id,      :uuid,  required: true

        field :name,    :string
        field :age,     :number
        field :amount,  :float
    end
end
```

### Blueprint types

- any 
- map
- enum
- atom
- uuid
- tuple
- float
- array
- struct
- number
- string
- boolean
- integer
- datetime

#### map

```elixir
defmodule Typed do
    use Blueprint.Struct

    @mapping [
        name:   [:string, length: [min: 5, max: 10]],
        value:  [:number, required: false]
    ]

    schema do
        # Define map with fields
        field :map_type, :map,  fields: @mapping
    end

end
```

#### nested types

```elixir
defmodule Nested do
    use Blueprint.Struct
    
    schema do
        field :value, :number
    end
end

defmodule Typed do
    use Blueprint.Struct

    schema do
        field :nested_array, :array, type: Nested,  default: []
    end
end
```

### Blueprint validators

- inclusion
- exclusion
- required 
- length
- format
- number
- fields
- struct
- uuid
- type
- by
- tld
- pattern

#### required

validate required, field must have a value except `nil`

```elixir
defmodule Typed do
    use Blueprint.Struct

    schema do
        field :name, :string,  required: true
    end
end
```


#### length

validate length

```elixir
defmodule Typed do
    use Blueprint.Struct

    schema do
        field :name, :string,  length: [min: 2, max: 20]
    end
end
```


#### pattern

validate pattern

```elixir
defmodule Typed do
    use Blueprint.Struct

    schema do
        field :email, :string, pattern: :email
    end
end
```

<!-- @moduledoc -->

## Customization

### Blueprint.Type
Blueprint types all implement the `Blueprint.Type.Behaviour` defining a new type
must implement this behaviour

```elixir
defmodule CustomInteger do
    @behaviour Blueprint.Type.Behaviour

    def cast(value, options) when is_integer(value) do
        {:ok, value}
    end

    def cast(value, options) do
        {:error, ["value must be integer"]}
    end

    def dump(data, options) do
        {:ok, data}
    end
end
```

### Blueprint.Validator
Blueprint types all implement the `Blueprint.Type.Behaviour` defining a new type
must implement this behaviour

```elixir
defmodule CustomValidator do
    @behaviour Blueprint.Validator.Behaviour

    # validate a value given a context and options 
    # defined in field definition
    def validate(value, context, options) do
        {:ok, value}
    end

    # vaidate return error tuple when value
    # value fails validation 
    def validate(value, context, options) do
        {:error, ["reason"]}
    end

end
```


Blueprint types and validators can be defined or overwritten using config

```elixir
config :types, Blueprint,
    map: CustomMapImpl,
    custom_integer: CustomInteger,
    typename1: CustomType,
    typename2: CustomTypeImpl2

config :validators, Blueprint,
    validatorname: CustomValidator,
    seondvalidator: CustomSecondValidatorImpl
```

use custom types and validators with Blueprint

```elixir
defmodule CustomType do
    use Blueprint.Struct

    # Define your struct.
    schema do
        #Define a field with type string
        field :name, :string, validatorname: [...opts]

        #Define a field with custom integer type
        field :age,  :custom_integer,   default: 10
    end
end
```

### Thats all there is to blueprint


## Todo

* [ ] Field documention
* [ ] Validation documention

