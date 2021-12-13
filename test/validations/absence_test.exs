defmodule AbsenceTestRecord do
    use Blueprint.Struct

    blueprint do
        field :name, :string, absence: true
    end

end

defmodule AbsenceTest do
    use ExUnit.Case

    test "keyword list, provided absence validation" do
        assert !Blueprint.valid?([name: "Foo"], name: [absence: true])
        assert Blueprint.valid?([name: ""], name: [absence: true])
        assert !Blueprint.valid?([items: [:a]], items: [absence: true])
        assert Blueprint.valid?([items: []], items: [absence: true])
        assert Blueprint.valid?([items: {}], items: [absence: true])
        assert Blueprint.valid?([name: "Foo"], id: [absence: true])
    end

    test "map, provided absence validation" do
        assert !Blueprint.valid?(%{name: "Foo"}, name: [absence: true])
        assert !Blueprint.valid?(%{"name" => "Foo"}, %{"name" => [absence: true]})
        assert Blueprint.valid?(%{name: ""}, name: [absence: true])
        assert !Blueprint.valid?(%{items: [:a]}, items: [absence: true])
        assert Blueprint.valid?(%{items: []}, items: [absence: true])
        assert Blueprint.valid?(%{items: {}}, items: [absence: true])
        assert Blueprint.valid?(%{name: "Foo"}, id: [absence: true])
        assert Blueprint.valid?(%{"name" => "Foo"}, name: [absence: true])
    end

    test "keyword list, included absence validation" do
        assert !Blueprint.valid?(name: "Foo", _rules: [name: [absence: true]])
        assert Blueprint.valid?(name: "Foo", _rules: [id: [absence: true]])
    end

    test "record, included absence validation" do
        assert !Blueprint.valid?(%AbsenceTestRecord{name: "I have a name"})
        assert Blueprint.valid?(%AbsenceTestRecord{name: nil})
        assert Blueprint.valid?(%AbsenceTestRecord{name: []})
        assert Blueprint.valid?(%AbsenceTestRecord{name: ""})
        assert Blueprint.valid?(%AbsenceTestRecord{name: {}})
    end
end
