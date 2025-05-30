# Draft

**Draft** is a library for building typed structs with built-in validation support.

## Usage

### Setup

Add `:draft` to your project's dependencies in `mix.exs`:

```elixir
{:draft, "~> 1.0"}
```

### General Usage

To define a simple Draft struct:

```elixir
defmodule Book do
  use Draft.Schema

  # Define your struct.
  schema required: true do
    field :id,        :string
    field :title,     :string, min: 1, max: 32
    field :author_id, :string
    field :isbn,      :integer, min: 1_000_000_000, max: 9_999_999_999_999
  end
end
```

### Construction

You can create a struct using `new`, `cast`, or `from_struct`. Only type information is checked during construction.

#### `new`

`new/1` raises an error for invalid types or missing required fields.

```elixir
# Using a keyword list
book = Book.new(id: "1", title: "Elixir Draft Tutorial", author_id: "2", isbn: 22222222222)

# Using a map
book = Book.new(%{
  id: "1",
  title: "Elixir Draft Tutorial",
  author_id: "2",
  isbn: 22222222222
})
```

#### `cast`

`cast/1` returns a result tuple: `{:ok, struct}` or `{:error, errors}`. `errors` is a keyword list.

```elixir
{:ok, book} = Book.cast(id: "1", title: "Elixir Draft Tutorial", author_id: "2", isbn: 22222222222)
```

#### `from_struct`

Use `from_struct/1` and `from_struct!/1` to create a struct from another struct. The bang version raises on errors.

```elixir
defmodule Document do
  use Draft.Schema

  schema required: true do
    field :id,        :string
    field :title,     :string, min: 1, max: 32
    field :author_id, :string
    field :history,   :list, type: :string, default: []
    field :isbn,      :integer, min: 1_000_000_000, max: 9_999_999_999_999
  end
end

doc = Document.new(id: "1", title: "Elixir Doc", author_id: "2", isbn: 22222222222, history: [])

book = Book.from_struct!(doc)
{:ok, book} = Book.from_struct(doc)
```

---

### Required Fields

By default, all fields can be `nil`. Use `required: true` in the schema to make all fields required.

```elixir
defmodule Person do
  use Draft.Schema
  schema required: true do
    field :id,    :uuid
    field :name,  :string
    field :age,   :number
    field :amount, :float
  end
end
```

Fields with default values are considered optional:

```elixir
field :amount, :float, default: nil
```

You can make individual fields required:

```elixir
field :id, :uuid, required: true
```

---

### Validation

Use `Draft.errors(struct)` to validate a Draft struct. Errors are returned as a keyword list.

```elixir
book = Book.new(id: "1", title: "Draft Errors", author_id: "2", isbn: 1)
[isbn: _] = Draft.errors(book)
```

---

### Inheritance

Draft supports inheritance via the `:extends` option, including validation rules and types.

```elixir
defmodule Book do
  use Draft.Schema

  schema required: true do
    field :id,        :string
    field :title,     :string, min: 1, max: 32
    field :author_id, :string
    field :isbn,      :integer, min: 1_000_000_000, max: 9_999_999_999_999
  end
end

defmodule Document do
  use Draft.Schema

  schema extends: Book do
    field :history, :list, type: :string, default: []
  end
end
```

**Multiple inheritance:**

```elixir
defmodule HasAuthor do
  schema required: true do
    field :author_id, :string
  end
end

defmodule HasISBN do
  schema do
    field :isbn, :integer, min: 1_000_000_000, max: 9_999_999_999_999
  end
end

defmodule Book do
  use Draft.Schema

  schema required: true, extends: [HasAuthor, HasISBN] do
    field :id,    :string
    field :title, :string, min: 1, max: 32
  end
end
```

**Overwriting fields:**

```elixir
defmodule Book do
  use Draft.Schema

  schema do
    field :id, :string
  end
end

defmodule Document do
  use Draft.Schema

  schema extends: Book do
    field :id, :uuid, overwrite: true
  end
end

# Invalid UUID
{:error, _} = Document.new(id: "1")

# Valid UUID
doc = Document.new(id: "00000000-0000-0000-0000-000000000000")
```

---

## Advanced Usage

### Map Fields

```elixir
defmodule Typed do
  use Draft.Schema

  @mapping [
    name:  [:string, length: [min: 5, max: 10]],
    value: [:number, required: false]
  ]

  schema do
    field :stats, :map, fields: @mapping
  end
end
```

### Nested Types

```elixir
defmodule Book do
  use Draft.Schema

  schema do
    field :title, :string
  end
end

defmodule Library do
  use Draft.Schema

  schema do
    field :books, :list, type: Book, default: []
  end
end
```

### Required Field Validation

```elixir
field :name, :string, required: true
```

### Length Validation

```elixir
field :name, :string, length: [min: 2, max: 20]
```

### Pattern Validation

```elixir
field :password, :string, pattern: ~r/^[[:alnum:]]+$/
```

---

## Customization

Draft types must implement both `Draft.Type.Behaviour` and `Draft.Validator.Behaviour`.

### Custom Type (`Draft.Type.Behaviour`)

```elixir
defmodule ISBN.Type do
  @behaviour Draft.Type.Behaviour

  def cast(value, _opts) when is_integer(value) and value in 1_000_000_000..999_999_999_999, do:
    {:ok, value}

  def cast(_value, _opts), do:
    {:error, ["value must be a valid ISBN"]}

  def dump(value, _opts), do:
    {:ok, value}
end
```

### Custom Validator (`Draft.Validator.Behaviour`)

```elixir
defmodule ISBN.Validator do
  @behaviour Draft.Validator.Behaviour

  def validate(value, opts), do: validate(value, nil, opts)

  def validate(value, _context, _opts), do:
    {:ok, value}

  def validate(_value, _context, _opts), do:
    {:error, ["reason"]}
end
```

### Configuration

In your `config/config.exs`:

```elixir
config :types, Draft,
  isbn: ISBN.Type

config :validators, Draft,
  isbn: ISBN.Validator
```

### Usage in Schema

```elixir
field :isbn_number, :isbn
```

---

## Built-in Types

* `any`
* `map`
* `enum`
* `atom`
* `uuid`
* `list`
* `tuple`
* `float`
* `struct`
* `number`
* `string`
* `boolean`
* `integer`
* `datetime`

## Built-in Validators

* `inclusion`
* `exclusion`
* `required`
* `length`
* `format`
* `number`
* `fields`
* `struct`
* `uuid`
* `type`
* `by`
* `tld`
* `pattern`

---

## TODO

* [ ] Field documentation
* [ ] Validation documentation




