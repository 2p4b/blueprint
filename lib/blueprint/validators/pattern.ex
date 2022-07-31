defmodule Blueprint.Validators.Pattern do
    alias Blueprint.Patterns
    use Blueprint.Validator

    def validate(value, class) when is_atom(class) do
        pattern = Patterns.pattern(class)
        validate(value, {class, pattern})
    end

    def validate(_value, {class, nil}) do
        {:error, "invalid pattern #{class}"}
    end

    def validate(value, {class, %Regex{}=pattern}) do
        matched =
            String.Chars.to_string(value)
            |> String.match?(pattern)

        if matched do
            {:ok, value}
        else
            {:error, "must match pattern #{class}"}
        end
    end

end




