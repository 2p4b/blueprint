defmodule Blueprint.Validators.Format do
    @moduledoc """
    Ensure a value matches a regular expression.

    ## Options

    * `:with`: The regular expression.
    * `:message`: Optional. A custom error message. May be in EEx format
      and use the fields described in "Custom Error Messages," below.

    The regular expression can be provided in place of the keyword list if no other options
    are needed.

    ## Examples

        iex> Blueprint.Validators.Format.validate("foo", ~r/^f/)
        :ok

        iex> Blueprint.Validators.Format.validate("foo", ~r/o{3,}/)
        {:error, "must have the correct format"}

        iex> Blueprint.Validators.Format.validate("foo", [with: ~r/^f/])
        :ok

        iex> Blueprint.Validators.Format.validate("bar", [with: ~r/^f/, message: "must start with an f"])
        {:error, "must start with an f"}

        iex> Blueprint.Validators.Format.validate("", [with: ~r/^f/, allow_blank: true])
        :ok

        iex> Blueprint.Validators.Format.validate(nil, [with: ~r/^f/, allow_nil: true])
        :ok

    ## Custom Error Messages Custom error messages (in EEx format),
    provided as :message, can use the following values:

        iex> Blueprint.Validators.Format.__validator__(:message_fields)
        [value: "The bad value", pattern: "The regex that didn't match"]

    An example:

        iex> Blueprint.Validators.Format.validate("bar", [with: ~r/"^f"/, message: "<%= value %> doesn't start with an f"])
        {:error, "bar doesn't start with an f"}
    """

    use Blueprint.Validator

    @message_fields [value: "The bad value", pattern: "The regex that didn't match"]
    def validate(value, options) when is_list(options) do
        unless_skipping(value, options) do
            pattern = Keyword.get(options, :with)

            msg ="must have the correct format"
            has_errors =Regex.match?(pattern, to_string(value))
            result(has_errors, message(options, msg, value: value, pattern: pattern))
        end
    end

    def validate(value, format) do
        if Regex.regex?(format), do: validate(value, with: format)
    end

    defp result(true, _), do: :ok
    defp result(false, message), do: {:error, message}

end
