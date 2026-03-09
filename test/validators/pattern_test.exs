defmodule Draft.Validator.PatternTest do
    use ExUnit.Case

    alias Draft.Validator.Pattern

    # ---- Schema for integration tests ----------------------------------------

    defmodule Contact do
        use Draft.Schema

        schema do
            field :email, :string, pattern: :email
        end
    end

    defmodule Labelled do
        use Draft.Schema

        schema do
            field :code, :string, pattern: ~r/^[A-Z]{3}-\d{4}$/
        end
    end

    # -------------------------------------------------------------------------

    describe "validate/2 with a named atom pattern" do
        # validate(value, class) when is_atom(class)
        # Looks up the regex from Draft.Patterns by name.

        test "returns {:ok, value} for a value matching :email pattern" do
            assert {:ok, "alice@example.com"} = Pattern.validate("alice@example.com", :email)
        end

        test "returns {:ok, value} for an email with subdomains" do
            assert {:ok, _} = Pattern.validate("user@mail.example.org", :email)
        end

        test "returns {:error, msg} for a string with no @ sign" do
            assert {:error, msg} = Pattern.validate("not-an-email", :email)
            assert msg =~ "email"
        end

        test "returns {:error, msg} for an empty string against :email" do
            assert {:error, msg} = Pattern.validate("", :email)
            assert msg =~ "email"
        end

        test "returns {:error, msg} for nil coerced to empty string against :email" do
            # to_string(nil) == "", which doesn't match the email regex
            assert {:error, _msg} = Pattern.validate(nil, :email)
        end

        test "returns {:error, msg} for an unknown named pattern" do
            # Draft.Patterns.pattern(:nonexistent) returns nil -> invalid pattern error
            assert {:error, msg} = Pattern.validate("anything", :nonexistent_pattern)
            assert msg =~ "invalid pattern"
        end

        test "returns {:error, msg} for :mac pattern with a non-MAC string" do
            assert {:error, _msg} = Pattern.validate("not-a-mac", :mac)
        end

        test "returns {:ok, value} for a valid MAC address with :mac pattern" do
            assert {:ok, _} = Pattern.validate("AA:BB:CC:DD:EE:FF", :mac)
        end
    end

    describe "validate/2 with a raw %Regex{} pattern" do
        # validate(value, %Regex{}=pattern)
        # Wraps the regex as {:regex, pattern} and delegates.

        test "returns {:ok, value} when the value matches the regex" do
            assert {:ok, "ABC-1234"} = Pattern.validate("ABC-1234", ~r/^[A-Z]{3}-\d{4}$/)
        end

        test "returns {:error, msg} when the value does not match the regex" do
            assert {:error, msg} = Pattern.validate("abc-1234", ~r/^[A-Z]{3}-\d{4}$/)
            assert msg =~ "regex"
        end

        test "returns {:error, msg} for an empty string against a non-empty regex" do
            assert {:error, _msg} = Pattern.validate("", ~r/^[A-Z]{3}-\d{4}$/)
        end

        test "returns {:ok, value} for a simple digit regex" do
            assert {:ok, "42"} = Pattern.validate("42", ~r/^\d+$/)
        end

        test "returns {:error, msg} for a non-digit string against digit regex" do
            assert {:error, _msg} = Pattern.validate("abc", ~r/^\d+$/)
        end
    end

    describe "validate/2 with an unknown/invalid pattern argument" do
        # validate(value, unknown) catch-all
        # Wraps as {unknown, nil} which hits the nil clause -> {:error, "invalid pattern …"}

        test "returns {:error, msg} for a plain string as pattern" do
            assert {:error, msg} = Pattern.validate("anything", "not_a_pattern")
            assert msg =~ "invalid pattern"
        end

        test "returns {:error, msg} for an integer as pattern" do
            assert {:error, msg} = Pattern.validate("anything", 42)
            assert msg =~ "invalid pattern"
        end
    end

    describe "schema integration" do
        test "Contact schema passes Draft.validate for a valid email" do
            struct = Contact.new(%{email: "bob@example.com"})
            assert {:ok, _} = Draft.validate(struct)
        end

        test "Contact schema fails Draft.validate for an invalid email" do
            struct = Contact.new(%{email: "not-an-email"})
            assert {:error, [{:email, _}]} = Draft.validate(struct)
        end

        test "Labelled schema passes Draft.validate for a code matching the inline regex" do
            struct = Labelled.new(%{code: "XYZ-9999"})
            assert {:ok, _} = Draft.validate(struct)
        end

        test "Labelled schema fails Draft.validate for a code not matching the inline regex" do
            struct = Labelled.new(%{code: "xy-99"})
            assert {:error, [{:code, _}]} = Draft.validate(struct)
        end
    end

end
