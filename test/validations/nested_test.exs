defmodule NestedTestRecord do
    use Blueprint.Struct

    blueprint do
        field :author,  :string, presence: true
        field :name,    :string, presence: true
    end

end

defmodule NestedTest do
    use ExUnit.Case

    test "nested" do
        assert Blueprint.valid?([author: [name: "Foo"]], %{[:author, :name] => [presence: true]})

        nested_errors = [{:error, [:author, :name], :presence, "must be present"}]

        assert nested_errors ==
            Blueprint.errors([author: [name: ""]], %{[:author, :name] => [presence: true]})
    end

    test "nested with _rules" do
        assert Blueprint.valid?(author: [name: "Foo"], _rules: %{[:author, :name] => [presence: true]})

        nested_errors = [{:error, [:author, :name], :presence, "must be present"}]

        assert nested_errors ==
            Blueprint.errors(author: [name: ""], _rules: %{[:author, :name] => [presence: true]})
    end

    test "nested in Record" do
        user = %UserTest{
            username: "actualuser",
            password: "abcdefghi",
            password_confirmation: "abcdefghi"
        }

        data = %{score: 3, user: user}
        payload = %{
            name: "username",
            age: 5,
            data: data,
            user: user,
            number: 10,
        }
        blueprint = BlueprintTest.new(payload)

        Blueprint.results(blueprint)
        assert Blueprint.valid?(user)
        assert Blueprint.valid?(blueprint)
        assert Blueprint.errors(blueprint) == []
    end

end