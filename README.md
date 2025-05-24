# Draft

<!-- @moduledoc -->

Draft is a library for building structs with runtime type validation.
Creating and validating structs has never been easier.
Inspired by Ecto.Schema

## Usage

### Setup

To use Draft in your project, add this to your Mix dependencies:

```elixir
{:draft, "~> 0.1.0"},
```


### General usage

To define a Simple blueprint struct

```elixir
defmodule StructType do
    use Draft.Schema

    # Define your struct.
    draft do
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
    use Draft.Schema
    draft do
        field :value, :number
    end
end

defmodule Typed do
    use Draft.Schema
    draft do
        # Nested field
        field :nested,  Nested,  default: nil
        field :name,    :string,   default: "my name"
    end
end
```

### Inheritance
Draft structs can inherit fields from other draft, their types and validation rules, using the `:extends` option
- `:extends`  Draft module or list of blueprint modules for inheriting from muliple bases

#### Inherit from single base
```elixir
defmodule Super do
    use Draft.Schema
    draft do
        field :super, :number
    end
end

defmodule Base do
    draft extends: Super do
        field :base, :number
    end
end

defmodule Child do
    use Draft.Schema
    draft extends: Base do
        field :child,  :number
    end
end

%Child{super: 1, base: 2, child: 3}
```

#### Inherit from multiple base modules
when inheriting from multiple bases, the next module in the list always overwrites any previously defined fields 


```elixir
    draft extends: [Base, Super]
```
the module `Super` will overwrite any fields already defined in `Base`

```elixir
defmodule Super do
    use Draft.Schema
    draft do
        field :super, :number
    end
end

defmodule Base do
    use Draft.Schema
    draft do
        field :base, :number
    end
end

defmodule Child do
    use Draft.Schema
    draft extends: [Base, Super] do
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
    use Draft.Schema
    draft do
        field :super, :number
    end
end

defmodule Base do
    use Draft.Schema
    draft do
        field :base, :number
    end
end

defmodule Child do
    use Draft.Schema
    draft extends: [Base, Super] do
        field :base, :string, overwrite: true
    end
end

%Child{super: 1, base: "2", child: 3}

```

### Methods

Draft defines a constructor `new` method to create
struct from map or list. Note: the new method will throw if 
validation of field type fails

```elixir
data = StructType.new(%{...})
```

Draft defines a constructor `cast` method to struct but unlike
the `new` method is returns the usual `{:ok, value}` or `{:error, reason}`

```elixir
{:ok, data} = StructType.cast(%{...})
```

```elixir
{:error, reason} = StructType.cast(123)
```

Draft defines a constructor `from_struct` just like `new` but made to look like
the familiar `Map.from_struct` is uses the `new` method and will throw if 
validation fails

```elixir
data = StructType.from_struct(%StructType{...})
```

Draft defines a `dump` method to dump the data to simple Map that can be easily 
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
    use Draft.Schema

    # This will make all fields required.
    draft [required: true] do
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
    use Draft.Schema

    # This will make all fields required.
    draft [required: true] do
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
    use Draft.Schema

    # This will make all fields nill by default except id.
    draft do
        # Ensure id is required
        field :id,      :uuid,  required: true

        field :name,    :string
        field :age,     :number
        field :amount,  :float
    end
end
```

### Draft types

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
    use Draft.Schema

    @mapping [
        name:   [:string, length: [min: 5, max: 10]],
        value:  [:number, required: false]
    ]

    draft do
        # Define map with fields
        field :map_type, :map,  fields: @mapping
    end

end
```

#### nested types

```elixir
defmodule Nested do
    use Draft.Schema
    
    draft do
        field :value, :number
    end
end

defmodule Typed do
    use Draft.Schema

    draft do
        field :nested_array, :array, type: Nested,  default: []
    end
end
```

### Draft validators

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
    use Draft.Schema

    draft do
        field :name, :string,  required: true
    end
end
```


#### length

validate length

```elixir
defmodule Typed do
    use Draft.Schema

    draft do
        field :name, :string,  length: [min: 2, max: 20]
    end
end
```


#### pattern

validate pattern

```elixir
defmodule Typed do
    use Draft.Schema

    draft do
        field :email, :string, pattern: :email
    end
end
```

<!-- @moduledoc -->

## Customization

### Draft.Type
Draft types all implement the `Draft.Type.Behaviour` defining a new type
must implement this behaviour

```elixir
defmodule CustomInteger do
    @behaviour Draft.Type.Behaviour

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

### Draft.Validator
Draft types all implement the `Draft.Type.Behaviour` defining a new type
must implement this behaviour

```elixir
defmodule CustomValidator do
    @behaviour Draft.Validator.Behaviour

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


Draft types and validators can be defined or overwritten using config

```elixir
config :types, Draft,
    map: CustomMapImpl,
    custom_integer: CustomInteger,
    typename1: CustomType,
    typename2: CustomTypeImpl2

config :validators, Draft,
    validatorname: CustomValidator,
    seondvalidator: CustomSecondValidatorImpl
```

use custom types and validators with Draft

```elixir
defmodule CustomType do
    use Draft.Schema

    # Define your struct.
    draft do
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

