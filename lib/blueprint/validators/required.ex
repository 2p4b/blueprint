defmodule Blueprint.Validators.Required do
    @moduledoc """
    Ensure a value is present.

    Blueprint uses the `Blueprint.Blank` protocol to determine "presence."
    Notably, empty strings and collections are not considered present.

    ## Options

    * `:message`: Optional. A custom error message. May be in EEx format
        and use the fields described in "Custom Error Messages," below.

    ## Examples

        iex> Blueprint.Validators.Required.validate(1, true)
        :ok

        iex> Blueprint.Validators.Required.validate(nil, true)
        {:error, "is required"}

        iex> Blueprint.Validators.Required.validate(false, true)
        {:error, "is required"}

        iex> Blueprint.Validators.Required.validate("", true)
        {:error, "is required"}

        iex> Blueprint.Validators.Required.validate([], true)
        {:error, "is required"}

        iex> Blueprint.Validators.Required.validate([], true)
        {:error, "is required"}

        iex> Blueprint.Validators.Required.validate([1], true)
        :ok

        iex> Blueprint.Validators.Required.validate({1}, true)
        :ok

    ## Custom Error Messages

    Custom error messages (in EEx format), provided as :message, can use
    the following values:

        iex> Blueprint.Validators.Required.__validator__(:message_fields)
        [value: "The bad value"]

    An example:

        iex> Blueprint.Validators.Required.validate([], message: "needs to be more sizable than <%= inspect value %>")
        {:error, "needs to be more sizable than []"}
    """
    use Blueprint.Validator

    @message_fields [value: "The bad value"]
    def validate(value, options) do
        if Blueprint.Blank.blank?(value) do
            {:error, message(options, "is required", value: value)}
        else
            :ok
        end
    end
end
