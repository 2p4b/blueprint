defmodule Blueprint.Validator.Exclusion do
    @moduledoc """
    Ensure a value is not a member of a list of values.

    ## Options

    * `:in`: The list.
    * `:message`: Optional. A custom error message. May be in EEx format
        and use the fields described in "Custom Error Messages," below.

    The list can be provided in place of the keyword list if no other options are needed.

    ## Examples

        iex> Blueprint.Validator.Exclusion.validate(1, [1, 2, 3])
        {:error, "must not be one of [1, 2, 3]"}

        iex> Blueprint.Validator.Exclusion.validate(1, [in: [1, 2, 3]])
        {:error, "must not be one of [1, 2, 3]"}

        iex> Blueprint.Validator.Exclusion.validate(1, [in: [1, 2, 3], message: "<%= value %> shouldn't be in <%= inspect list %>"])
        {:error, "1 shouldn't be in [1, 2, 3]"}

        iex> Blueprint.Validator.Exclusion.validate(4, [1, 2, 3])
        {:ok, 4}

        iex> Blueprint.Validator.Exclusion.validate("a", ~w(a b c))
        {:error, ~S(must not be one of ["a", "b", "c"])}

        iex> Blueprint.Validator.Exclusion.validate("a", in: ~w(a b c), message: "must not be abc, talkin' 'bout 123")
        {:error, "must not be abc, talkin' 'bout 123"}

    """
    use Blueprint.Validator

    @message_fields [value: "The bad value", list: "List"]
    def validate(value, options) when is_list(options) do
        if Keyword.keyword?(options) do
            unless_skipping(value, options) do
                list = Keyword.get(options, :in)

                msg = "must not be one of #{inspect(list)}"

                has_errors =!Enum.member?(list, value)

                result(has_errors, value, message(options, msg, value: value, list: list))
            end
        else
            validate(value, in: options)
        end
    end

    defp result(true, value, _), do: {:ok, value}
    defp result(false, _value, message), do: {:error, message}

end
