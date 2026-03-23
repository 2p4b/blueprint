# Draft

[![Hex.pm](https://img.shields.io/hexpm/v/draft.svg)](https://hex.pm/packages/draft)
[![License](https://img.shields.io/hexpm/l/draft.svg)](https://github.com/2p4b/blueprint/blob/main/LICENSE)

**Draft** is an Elixir library for building typed structs with built-in type 
coercion and validation. Define schemas with type safety, automatic casting, 
and flexible validation rules.

## Installation

Add `draft` to your dependencies in `mix.exs`:

```elixir
def deps do
    [
        {:draft, "~> 1.1.1"}
    ]
end
```

## Quick Start

```elixir
defmodule User do
    use Draft.Schema

    schema required: true do
        field :id,    :uuid
        field :name,  :string, min: 1, max: 100
        field :email, :string, pattern: :email
        field :age,   :integer, min: 0
    end
end

# Create a struct, raises on error
user = User.new!(
  id: "550e8400-e29b-41d4-a716-446655440000",
  name: "Alice",
  email: "alice@example.com",
  age: 30
)

# Create with result tuple
{:ok, user} = User.cast(%{
  "id" => "550e8400-e29b-41d4-a716-446655440000",
  "name" => "Alice",
  "email" => "alice@example.com",
  "age" => "30"
})

# Validate
[] = Draft.errors(user)  # No errors
```

## Defining Schemas

Use `Draft.Schema` to define typed structs:

```elixir
defmodule Book do
    use Draft.Schema

    schema do
        field :title,     :string
        field :author,    :string
        field :isbn,      :integer
        field :published, :datetime
    end
end
```

### Required Fields

By default, all fields are optional (can be `nil`). Use `required: true`
at the schema level to make all fields required:

```elixir
schema required: true do
    field :id,    :uuid
    field :name,  :string
    field :email, :string
end
```

Or mark individual fields as required:

```elixir
schema do
    field :id,    :uuid, required: true
    field :name,  :string
    field :notes, :string  # optional
end
```

Fields with default values are automatically optional:

```elixir
field :status, :string, default: "pending"
```

## Construction

### `new!/1`

Creates a struct, raising `ArgumentError` on invalid types or missing
required fields:

```elixir
# From keyword list
book = Book.new!(title: "Elixir in Action", author: "Sasa Juric", isbn: 1234567890)

# From map
book = Book.new!(%{title: "Elixir in Action", author: "Sasa Juric", isbn: 1234567890})

# String keys are automatically converted
book = Book.new!(%{"title" => "Elixir in Action", "author" => "Sasa Juric"})
```

### `cast/1`

Returns a result tuple without raising:

```elixir
{:ok, book} = Book.cast(title: "Elixir in Action", author: "Sasa Juric")
{:error, reason} = Book.cast(title: 123)  # Type coercion error
```

### `from_struct/2`

Creates a struct from another struct, useful for transforming between similar types:

```elixir
defmodule Document do
    use Draft.Schema
    schema do
        field :title, :string
        field :body,  :string
        field :meta,  :map
    end
end

defmodule Article do
    use Draft.Schema
    schema do
        field :title,   :string
        field :content, :string
    end
end

doc = Document.new(title: "Hello", body: "World", meta: %{})

# Direct conversion (matching field names)
article = Article.from_struct(doc)

# With field remapping
article = Article.from_struct(doc, content: :body)
```

Returns the struct on success or `{:error, reason}` on failure.

## Type Coercion

Draft automatically coerces values to the correct type during construction:

```elixir
defmodule Example do
    use Draft.Schema
    schema do
        field :count,  :integer
        field :price,  :float
        field :active, :boolean
    end
end

# String values are coerced
Example.new(count: "42", price: "19.99", active: "true")
# => %Example{count: 42, price: 19.99, active: true}
```

## Validation

Validation is separate from construction. Use `Draft.validate/1` or
`Draft.errors/1` to validate a struct:

```elixir
defmodule Product do
    use Draft.Schema
    schema do
        field :name,  :string, min: 1, max: 100
        field :price, :number, min: 0
        field :sku,   :string, pattern: ~r/^[A-Z]{3}-\d{4}$/
    end
end

product = Product.new(name: "", price: -10, sku: "invalid")

# Get validation errors
errors = Draft.errors(product)
# => [
#   name: "must be greater than 1",
#   price: "must be greater than 0",
#   sku: "does not match the required format"
# ]

# Check if valid
Draft.valid?(product)  # => false

# Validate with result tuple
{:error, errors} = Draft.validate(product)
```

### Built-in Validators

| Validator | Options | Description |
|-----------|---------|-------------|
| `required` | `true` | Field must not be nil |
| `min` | integer | Minimum value (numbers) or length (strings/lists) |
| `max` | integer | Maximum value (numbers) or length (strings/lists) |
| `length` | `min:`, `max:`, `is:`, `in:` | Exact length constraints |
| `format` | `:email`, `:url`, or regex | String format validation |
| `pattern` | regex | Custom regex pattern |
| `inclusion` | list or `in:` | Value must be in list |
| `exclusion` | list or `in:` | Value must not be in list |
| `by` | function | Custom validation function |
| `uuid` | `true` | Valid UUID format |
| `tld` | `true` | Valid top-level domain |

### Validation Examples

```elixir
# Length validation
field :username, :string, length: [min: 3, max: 20]
field :pin,      :string, length: [is: 4]
field :code,     :string, length: [in: 6..10]

# Numeric bounds
field :age,   :integer, min: 0, max: 150
field :score, :number,  min: 0, max: 100

# Pattern matching
field :phone, :string, pattern: ~r/^\+?[\d\s-]+$/
field :email, :string, format: :email

# Inclusion/Exclusion
field :status, :string, inclusion: ["pending", "active", "closed"]
field :role,   :atom,   exclusion: [:admin, :superuser]

# Custom validation
field :even_number, :integer, by: fn val -> rem(val, 2) == 0 end
```

### Custom Error Messages

Validators accept a `:message` option for custom error messages with EEx templating:

```elixir
field :age, :integer, min: [min: 18, message: "must be at least <%= min %> years old"]
field :name, :string,
  length: [min: 2, message: "<%= value %> is too short (min <%= min %> chars)"]
```

### Conditional Validation

Skip validation based on conditions:

```elixir
# Skip if value is nil
field :nickname, :string, min: [min: 3, allow_nil: true]

# Skip if value is blank (nil or empty string)
field :bio, :string, length: [max: 500, allow_blank: true]
```

## Built-in Types

| Type | Description | Coerces From |
|------|-------------|--------------|
| `:string` | Text values | Any value via `to_string/1` |
| `:integer` | Whole numbers | Strings, floats |
| `:float` | Decimal numbers | Strings, integers |
| `:number` | Any numeric value | Strings |
| `:boolean` | True/false | `"true"`, `"false"`, `1`, `0` |
| `:atom` | Atoms | Strings (existing atoms only) |
| `:uuid` | UUID strings | Strings |
| `:datetime` | DateTime structs | ISO8601 strings |
| `:map` | Maps | - |
| `:list` | Lists | - |
| `:tuple` | Tuples | - |
| `:enum` | Enumerated values | Strings, atoms |
| `:struct` | Struct types | Maps |
| `:any` | Any value | - |

## Advanced Features

### Nested Schemas

Use Draft schemas as field types:

```elixir
defmodule Address do
    use Draft.Schema
    schema do
        field :street,  :string
        field :city,    :string
        field :country, :string
    end
end

defmodule Person do
    use Draft.Schema
    schema do
        field :name,    :string
        field :address, Address
    end
end

Person.new(
  name: "Alice",
  address: %{street: "123 Main St", city: "Boston", country: "USA"}
)
```

### Lists of Schemas

```elixir
defmodule Order do
    use Draft.Schema
    schema do
        field :items, :list, type: LineItem, default: []
    end
end
```

### Enum Types

```elixir
field :status, :enum, values: [:pending, :processing, :shipped, :delivered]
```

### Map Fields with Schema

Define typed map fields without creating a separate module:

```elixir
defmodule Report do
    use Draft.Schema

    @metadata_schema [
        author:    [:string, required: true],
        version:   [:integer, min: 1],
        tags:      [:list, type: :string]
    ]

    schema do
        field :title,    :string
        field :metadata, :map, fields: @metadata_schema
    end
end
```

### Inheritance

Extend existing schemas with the `:extends` option:

```elixir
defmodule Entity do
    use Draft.Schema
    schema do
        field :id,         :uuid
        field :created_at, :datetime
        field :updated_at, :datetime
    end
end

defmodule User do
    use Draft.Schema
    schema extends: Entity do
        field :name,  :string
        field :email, :string
    end
end

# User has all fields from Entity plus its own:
# %User{id: nil, created_at: nil, updated_at: nil, name: nil, email: nil}
user = User.new(
  id: "550e8400-e29b-41d4-a716-446655440000",
  name: "Alice",
  email: "alice@example.com"
)
```

**Inheriting required fields:**

If the parent schema is defined with `required: true`, child schemas
inherit that enforcement:

```elixir
defmodule Entity do
    use Draft.Schema
    schema required: true do
        field :id,         :uuid
        field :created_at, :datetime
    end
end

defmodule Post do
    use Draft.Schema
    schema extends: Entity do
        field :title, :string, required: true
        field :body,  :string  # optional
    end
end

# :id, :created_at, and :title are all required
Post.new(title: "Hello")  # raises — :id and :created_at are missing
```

**Multi-level inheritance:**

```elixir
defmodule Timestamps do
    use Draft.Schema
    schema do
        field :created_at, :datetime
        field :updated_at, :datetime
    end
end

defmodule Entity do
    use Draft.Schema
    schema extends: Timestamps do
        field :id, :uuid
    end
end

defmodule User do
    use Draft.Schema
    schema extends: Entity do
        field :name,  :string
        field :email, :string
    end
end

# User inherits from Entity which inherits from Timestamps:
# %User{created_at: nil, updated_at: nil, id: nil, name: nil, email: nil}
```

**Multiple inheritance:**

```elixir
defmodule Timestamps do
    use Draft.Schema
    schema do
        field :created_at, :datetime
        field :updated_at, :datetime
    end
end

defmodule SoftDelete do
    use Draft.Schema
    schema do
        field :deleted_at, :datetime
    end
end

defmodule Post do
    use Draft.Schema
    schema extends: [Timestamps, SoftDelete] do
        field :title, :string
        field :body,  :string
    end
end

# Post has: created_at, updated_at, deleted_at, title, body
```

**Overwriting inherited fields:**

Use `overwrite: true` on a field to replace an inherited field's type or validators:

```elixir
defmodule User do
    use Draft.Schema
    schema extends: Entity do
        field :name,  :string
        field :email, :string  # no format validation
    end
end

defmodule Admin do
    use Draft.Schema
    schema extends: User do
        # Replace the inherited :email with a stricter version
        field :email, :string, overwrite: true, format: :email
    end
end

admin = Admin.new(name: "Bob", email: "not-an-email")
Draft.valid?(admin)  # => false — format: :email is now enforced
```


### Serialization (Dump)

Convert structs back to plain maps:

```elixir
user = User.new(name: "Alice", email: "alice@example.com")
{:ok, map} = User.dump(user)
# => {:ok, %{"name" => "Alice", "email" => "alice@example.com"}}
```

## Custom Types

Implement `Draft.Type.Behaviour` for custom types:

```elixir
defmodule MyApp.Types.Money do
    @behaviour Draft.Type.Behaviour

    @impl true
    def cast(value, _opts) when is_integer(value) do
        {:ok, Decimal.new(value)}
    end

    def cast(value, _opts) when is_binary(value) do
    case Decimal.parse(value) do
        {decimal, ""} -> {:ok, decimal}
        _ -> {:error, ["invalid money format"]}
    end
    end

    def cast(_, _), do: {:error, ["invalid money format"]}

    @impl true
    def dump(value, _opts) do
        {:ok, Decimal.to_string(value)}
    end
end
```

## Custom Validators

Implement `Draft.Validator.Behaviour`:

```elixir
defmodule MyApp.Validators.Positive do
    use Draft.Validator

    def validate(value, _opts) when is_number(value) and value > 0 do
        {:ok, value}
    end

    def validate(_value, opts) do
        {:error, message(opts, "must be positive")}
    end
end
```

### Configuration

Register custom types and validators in `config/config.exs`:

```elixir
config :draft, :types,
    money: MyApp.Types.Money

config :draft, :validators,
    positive: MyApp.Validators.Positive
```

Then use them in schemas:

```elixir
field :amount, :money, positive: true
```

## API Reference

### Schema Functions

| Function | Description |
|----------|-------------|
| `new!/1` | Create struct, raises on error |
| `new/1` | Deprecated alias for `new!/1` |
| `cast/1` | Create struct, returns result tuple |
| `from_struct/2` | Create from another struct with optional field remapping |
| `dump/1` | Serialize struct to map |

### Draft Functions

| Function | Description |
|----------|-------------|
| `Draft.valid?/1` | Check if struct is valid |
| `Draft.validate/1` | Validate and return result tuple |
| `Draft.errors/1` | Get list of validation errors |

## License

MIT License - see [LICENSE](LICENSE) for details.
