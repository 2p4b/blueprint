defmodule Blueprint.Validator.Required do
    use Blueprint.Validator

    @message_fields [value: "The bad value"]
    def validate(value, false) do
        {:ok, value}
    end
    def validate(value, options) do
        if is_nil(value) do
            {:error, message(options, "must not be nil", value: value)}
        else
            {:ok, value}
        end
    end
end
