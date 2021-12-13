defmodule NestedTestRecord do
    defstruct author: nil
    use Blueprint.Struct

    validates([:author, :name], presence: true)
end

defmodule NestedTest do
    use ExUnit.Case

    test "nested" do
        assert Blueprint.valid?([author: [name: "Foo"]], %{[:author, :name] => [presence: true]})

        nested_errors = [{:error, [:author, :name], :presence, "must be present"}]

        assert nested_errors ==
            Blueprint.errors([author: [name: ""]], %{[:author, :name] => [presence: true]})
    end

    test "nested with _vex" do
        assert Blueprint.valid?(author: [name: "Foo"], _vex: %{[:author, :name] => [presence: true]})

        nested_errors = [{:error, [:author, :name], :presence, "must be present"}]

        assert nested_errors ==
            Blueprint.errors(author: [name: ""], _vex: %{[:author, :name] => [presence: true]})
    end

    test "nested in Record" do
        assert Blueprint.valid?(%NestedTestRecord{author: [name: "Foo"]})

        nested_errors = [{:error, [:author, :name], :presence, "must be present"}]
        assert nested_errors == Blueprint.errors(%NestedTestRecord{author: [name: ""]})
    end
end
