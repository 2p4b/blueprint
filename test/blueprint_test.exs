defmodule SchemaTest do
    use ExUnit.Case

    test "invalid validation name error is raised" do
        assert_raise Blueprint.InvalidValidatorError, fn ->
            Blueprint.valid?([name: "Foo"], name: [foobar: true])
        end
    end

    test "keyword list, provided multiple validations" do
        assert Blueprint.valid?([name: "Foo"],
            name: [presence: true, length: [min: 2, max: 10], format: ~r(^Fo.$)]
        )
    end

    @tag :blueprint
    test "blueprint has nested struct" do
        user = %UserTest{
            username: "actualuser",
            password: "abcdefghi",
            password_confirmation: "abcdefghi"
        }
        data = %{
            score: 3,
            user: user,
        }
        number = 5
        payload = %{
            name: "username",
            age: 5,
            number: number,
            data: data,
            user: user
        }
        blueprint = BlueprintTest.new(payload)
        assert Blueprint.valid?(blueprint)
        assert Blueprint.errors(blueprint) == []
    end

    test "record, included complex validation" do
        user = %UserTest{
            username: "actualuser",
            password: "abcdefghi",
            password_confirmation: "abcdefghi"
        }

        assert Blueprint.valid?(user)
        assert Blueprint.results(user) != []
        assert Blueprint.errors(user) == []
        assert UserTest.valid?(user)
    end

    test "keyword list, included complex validation" do
        user = [
            username: "actualuser",
            password: "abcdefghi",
            password_confirmation: "abcdefghi",
            _vex: [
                username: [presence: true, length: [min: 4], format: ~r(^[[:alpha:]][[:alnum:]]+$)],
                password: [length: [min: 4], confirmation: true]
            ]
        ]

        assert Blueprint.valid?(user)
        assert length(Blueprint.results(user)) > 0
        assert Blueprint.errors(user) == []
    end

    test "keyword list, included complex validation with errors" do
        user = [
            username: "actualuser",
            password: "abc",
            password_confirmation: "abcdefghi",
            _vex: [
                username: [presence: true, length: [min: 4], format: ~r(^[[:alpha:]][[:alnum:]]+$)],
                password: [length: [min: 4], confirmation: true]
            ]
        ]

        assert !Blueprint.valid?(user)
        assert length(Blueprint.results(user)) > 0
        assert length(Blueprint.errors(user)) == 2
    end

    test "keyword list, included complex validation with non-applicable validations" do
        user = [
            username: "actualuser",
            password: "abcd",
            password_confirmation: "abcdefghi",
            state: :persisted,
            _vex: [
                username: [presence: true, length: [min: 4], format: ~r(^[[:alpha:]][[:alnum:]]+$)],
                password: [length: [min: 4, if: [state: :new]], confirmation: [if: [state: :new]]]
                ]
                ]

                assert Blueprint.valid?(user)
                end

            test "validate returns {:ok, data} on success" do
            assert {:ok, [name: "Foo"]} =
                Blueprint.validate([name: "Foo"], name: [length: [min: 2, max: 10], format: ~r(^Fo.$)])
            end

            test "validate returns {:error, errors} on error" do
                assert {:error, [{:error, :name, :length, "must have a length of at least 4"}]} =
                    Blueprint.validate([name: "Foo"], name: [length: [min: 4]])
            end

            test "validator lookup by structure" do
                validator = Blueprint.validator(:criteria, [TestValidatorSourceByStructure])
                assert validator == TestValidatorSourceByStructure.Criteria
            end

            test "validator lookup by function" do
                validator = Blueprint.validator(:criteria, [TestValidatorSourceByFunction])
                assert validator == TestValidatorSourceByFunctionResult
            end
end
