defmodule Blueprint.Validators.Inclusion do
    @moduledoc """
    Ensure a value is a member of a list of values.

    ## Options

    * `:in`: The list.
    * `:message`: Optional. A custom error message. May be in EEx format
      and use the fields described in "Custom Error Messages," below.

    The list can be provided in place of the keyword list if no other options are needed.

    ## Examples

        iex> Blueprint.Validators.Inclusion.validate(1, [1, 2, 3])
        {:ok, [1,2,3]}

        iex> Blueprint.Validators.Inclusion.validate(1, [in: [1, 2, 3]])
        {:ok, [1,2,3]}

        iex> Blueprint.Validators.Inclusion.validate(4, [1, 2, 3])
        {:error, "must be one of [1, 2, 3]"}

        iex> Blueprint.Validators.Inclusion.validate("a", ~w(a b c))
        {:ok, ~w(a b c)}

        iex> Blueprint.Validators.Inclusion.validate(nil, ~w(a b c))
        {:error, ~S(must be one of ["a", "b", "c"])}

        iex> Blueprint.Validators.Inclusion.validate(nil, [in: ~w(a b c), allow_nil: true])
        {:ok, nil}

        iex> Blueprint.Validators.Inclusion.validate("", [in: ~w(a b c), allow_blank: true])
        {:ok, ""}

    ## Custom Error Messages

    Custom error messages (in EEx format), provided as :message, can use the following values:

        iex> Blueprint.Validators.Inclusion.__validator__(:message_fields)
        [value: "The bad value", list: "List"]

    An example:

        iex> Blueprint.Validators.Inclusion.validate("a", in: [1, 2, 3], message: "<%= inspect value %> is not an allowed value")
        {:error, ~S("a" is not an allowed value)}

    """
    use Blueprint.Validator

    @message_fields [value: "The bad value", list: "List"]
    def validate(value, options) when is_list(options) do
        if Keyword.keyword?(options) do
            unless_skipping(value, options) do
                list = Keyword.get(options, :in)
                msg = "must be one of #{inspect(list)}"
                has_errors = Enum.member?(list, value)
                result(has_errors, value, message(options, msg, value: value, list: list))
            end
        else
            validate(value, in: options)
        end
    end

    defp result(true, value, _), do: {:ok, value}
    defp result(false, _value, message), do: {:error, message}

end
