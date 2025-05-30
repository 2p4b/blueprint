defmodule Draft.Validator.Min do
    @moduledoc """
    Ensure a value's value meets a constraint.

    ## Examples

        iex> Draft.Validator.Min.validate(3, 3)
        {:ok, 3}

        iex> Draft.Validator.Min.validate(4, 5)
        {:error, "must be greater than 5"}

        iex> Draft.Validator.Min.validate("foo", 3)
        {:ok, "foo"}

        iex> Draft.Validator.Min.validate([1], 3)
        {:error, "must be greater than 3"}

        iex> Draft.Validator.Min.validate([1, 2, 3], 3)
        {:ok, [1, 2, 3]}

        iex> Draft.Validator.Min.validate("foo", 4)
        {:error, "must be greater than 4"}

        iex> Draft.Validator.Min.validate("foo", min: 4, message: "must be the right length")
        {:error, "must be the right length"}
    """
    use Draft.Validator

    def validate(value, _context, option) do
        validate(value, option)
    end

    def validate(value, option) when is_number(option) do
        validate(value, min: option)
    end

    def validate(value, options) when is_list(options) do
        min_value = Keyword.fetch!(options, :min) 
        size_value = 
              cond do
                  is_number(value) ->
                      value

                  is_binary(value) ->
                      value
                      |> String.graphemes()
                      |> length()

                  is_list(value) or is_tuple(value) ->
                      length(value)

                  true ->
                      0
              end

      if size_value < min_value do
          {:error, message(options, "must be greater than #{min_value}", value: value)}
      else
          {:ok, value}
      end

    end

end

