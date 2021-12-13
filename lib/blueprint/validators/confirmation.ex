defmodule Blueprint.Validators.Confirmation do
    @moduledoc """
    Ensure a value, if provided, is equivalent to a second value.

    Generally used to check, eg, a password and password
    confirmation.

    Note: This validator is treated differently by Blueprint, in that
    two values are passed to it.

    ## Options

    * `:message`: Optional. A custom error message. May be in EEx format
      and use the fields described in "Custom Error Messages," below.

    ## Examples

        iex> Blueprint.Validators.Confirmation.validate(["foo", "bar"], true)
        {:error, "must match its confirmation"}

        iex> Blueprint.Validators.Confirmation.validate(["foo", "foo"], true)
        :ok

        iex> Blueprint.Validators.Confirmation.validate(["foo", "bar"], message: "<%= confirmation %> isn't the same as <%= value %>!")
        {:error, "bar isn't the same as foo!"}

        iex> Blueprint.Validators.Confirmation.validate([nil, "bar"], true)
        :ok

        iex> Blueprint.Validators.Confirmation.validate(["foo", nil], true)
        {:error, "must match its confirmation"}

        iex> Blueprint.Validators.Confirmation.validate(["foo", nil], message: "must match!")
        {:error, "must match!"}

        iex> Blueprint.Validators.Confirmation.validate(["", "unneeded"], [allow_blank: true])
        :ok

    ## Custom Error Messages

    Custom error messages (in EEx format), provided as :message, can use the following values:

        iex> Blueprint.Validators.Confirmation.__validator__(:message_fields)
        [value: "The value to confirm", confirmation: "Bad confirmation value"]

    An example:

        iex> Blueprint.Validators.Confirmation.validate(["foo", nil], message: "<%= inspect confirmation %> doesn't match <%= inspect value %>")
        {:error, ~S(nil doesn't match "foo")}

    """
    use Blueprint.Validator

    @message_fields [value: "The value to confirm", confirmation: "Bad confirmation value"]
    def validate(values, true), do: validate(values, [])
    def validate([nil | _], _options), do: :ok

    def validate([value, confirmation] = values, options) when is_list(options) do
        unless_skipping(value, options) do
            if values |> Enum.uniq() |> length == 1 do
                :ok
            else
                {:error,
                    message(options, "must match its confirmation", value: value, confirmation: confirmation)}
            end
        end
    end
end
