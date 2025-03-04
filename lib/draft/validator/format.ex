defmodule Draft.Validator.Format do
    @moduledoc """
    Ensure a value matches a regular expression.

    ## Options

    * `:with`: The regular expression.
    * `:message`: Optional. A custom error message. May be in EEx format
      and use the fields described in "Custom Error Messages," below.

    The regular expression can be provided in place of the keyword list if no other options
    are needed.

    ## Examples

        iex> Draft.Validator.Format.validate("foo", ~r/^f/)
        {:ok, "foo"}

        iex> Draft.Validator.Format.validate("foo", ~r/o{3,}/)
        {:error, "must have the correct format"}

        iex> Draft.Validator.Format.validate("foo", [with: ~r/^f/])
        {:ok, "foo"}

        iex> Draft.Validator.Format.validate("bar", [with: ~r/^f/, message: "must start with an f"])
        {:error, "must start with an f"}

        iex> Draft.Validator.Format.validate("", [with: ~r/^f/, allow_blank: true])
        {:ok, ""}

        iex> Draft.Validator.Format.validate(nil, [with: ~r/^f/, allow_nil: true])
        {:ok, nil}
    """

    use Draft.Validator

    @message_fields [value: "The bad value", pattern: "The regex that didn't match"]
    def validate(value, options) when is_list(options) do
        unless_skipping(value, options) do
            pattern = Keyword.get(options, :with)

            msg ="must have the correct format"
            has_errors =Regex.match?(pattern, to_string(value))
            result(has_errors, value, message(options, msg, value: value, pattern: pattern))
        end
    end

    def validate(value, format) do
        if Kernel.is_struct(format, Regex), do: validate(value, with: format)
    end

    defp result(true, value, _), do: {:ok, value}
    defp result(false,_value, message), do: {:error, message}

end
