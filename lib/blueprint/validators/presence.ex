defmodule Blueprint.Validators.Presence do
    @moduledoc """
    Ensure a value is present.

    Blueprint uses the `Blueprint.Blank` protocol to determine "presence."
    Notably, empty strings and collections are not considered present.

    ## Options

    * `:message`: Optional. A custom error message. May be in EEx format
        and use the fields described in "Custom Error Messages," below.

    ## Examples

        iex> Blueprint.Validators.Presence.validate(1, true)
        :ok

        iex> Blueprint.Validators.Presence.validate(nil, true)
        {:error, "must be present"}

        iex> Blueprint.Validators.Presence.validate(false, true)
        {:error, "must be present"}

        iex> Blueprint.Validators.Presence.validate("", true)
        {:error, "must be present"}

        iex> Blueprint.Validators.Presence.validate([], true)
        {:error, "must be present"}

        iex> Blueprint.Validators.Presence.validate([], true)
        {:error, "must be present"}

        iex> Blueprint.Validators.Presence.validate([1], true)
        :ok

        iex> Blueprint.Validators.Presence.validate({1}, true)
        :ok

    ## Custom Error Messages

    Custom error messages (in EEx format), provided as :message, can use
    the following values:

        iex> Blueprint.Validators.Presence.__validator__(:message_fields)
        [value: "The bad value"]

    An example:

        iex> Blueprint.Validators.Presence.validate([], message: "needs to be more sizable than <%= inspect value %>")
        {:error, "needs to be more sizable than []"}
    """
    use Blueprint.Validator

    @message_fields [value: "The bad value"]
    def validate(value, options) do
        if Blueprint.Blank.blank?(value) do
            {:error, message(options, "must be present", value: value)}
        else
            :ok
        end
    end
end
