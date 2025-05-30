defmodule Draft.Validator.Max do
    @moduledoc """
    Ensure a value's value meets a constraint.

    ## Examples

        iex> Draft.Validator.Max.validate(3, 3)
        {:ok, 3}

        iex> Draft.Validator.Max.validate(6, 5)
        {:error, "must be less than 5"}

        iex> Draft.Validator.Max.validate("foo", 3)
        {:ok, "foo"}

        iex> Draft.Validator.Max.validate([1, 2, 3, 4], 3)
        {:error, "must be less than 3"}

        iex> Draft.Validator.Max.validate([1, 2, 3], 3)
        {:ok, [1, 2, 3]}

        iex> Draft.Validator.Max.validate("foobar", 4)
        {:error, "must be less than 4"}

        iex> Draft.Validator.Max.validate("foobar", max: 4, message: "must be the right length")
        {:error, "must be the right length"}
    """
    use Draft.Validator

    def validate(value, _context, option) do
        validate(value, option)
    end

    def validate(value, option) when is_number(option) do
        validate(value, max: option)
    end

    def validate(value, options) when is_list(options) do
        max_value = Keyword.fetch!(options, :max) 
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

      if size_value > max_value do
          {:error, message(options, "must be less than #{max_value}", value: value)}
      else
          {:ok, value}
      end

    end

end

