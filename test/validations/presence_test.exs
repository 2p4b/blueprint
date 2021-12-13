defmodule PresenceTest do
    use ExUnit.Case

    test "keyword list, provided presence validation" do
        assert Blueprint.valid?([name: "Foo"], name: [presence: true])
        assert !Blueprint.valid?([name: ""], name: [presence: true])
        assert Blueprint.valid?([items: [:a]], items: [presence: true])
        assert !Blueprint.valid?([items: []], items: [presence: true])
        assert !Blueprint.valid?([items: {}], items: [presence: true])
        assert !Blueprint.valid?([name: "Foo"], id: [presence: true])
        assert Blueprint.valid?([total: 0.0], total: [presence: true])
        assert Blueprint.valid?([total: 1.0], total: [presence: true])
        assert Blueprint.valid?([total: 0], total: [presence: true])
        assert Blueprint.valid?([total: 1], total: [presence: true])
        assert Blueprint.valid?([date: Date.utc_today()], date: [presence: true])
        assert Blueprint.valid?([date: NaiveDateTime.utc_now()], date: [presence: true])
        assert Blueprint.valid?([date: DateTime.utc_now()], date: [presence: true])
        assert Blueprint.valid?([date: Time.utc_now()], date: [presence: true])
        refute Blueprint.valid?([date: nil], date: [presence: true])
    end

    test "map, provided presence validation" do
        assert Blueprint.valid?([name: "Foo"], name: [presence: true])
        assert !Blueprint.valid?(%{name: "Foo"}, id: [presence: true])
        assert Blueprint.valid?(%{"name" => "Foo"}, %{"name" => [presence: true]})

        assert Blueprint.valid?(%{"name" => "Foo", "age" => 21}, %{
            "name" => [presence: true],
            "age" => [presence: true]
        })

        assert !Blueprint.valid?(%{"name" => "Foo"}, %{
            "name" => [presence: true],
            "age" => [presence: true]
        })

        assert !Blueprint.valid?(%{"name" => "Foo"}, %{"id" => [presence: true]})
        assert !Blueprint.valid?(%{"name" => "Foo"}, name: [presence: true])
        assert Blueprint.valid?(%{"date" => Date.utc_today()}, %{"date" => [presence: true]})
        assert Blueprint.valid?(%{"date" => DateTime.utc_now()}, %{"date" => [presence: true]})
        assert Blueprint.valid?(%{"date" => NaiveDateTime.utc_now()}, %{"date" => [presence: true]})
        assert Blueprint.valid?(%{"date" => Time.utc_now()}, %{"date" => [presence: true]})
        refute Blueprint.valid?(%{"date" => nil}, %{"date" => [presence: true]})
    end

    test "keyword list, included presence validation" do
        assert Blueprint.valid?(name: "Foo", _rules: [name: [presence: true]])
        assert !Blueprint.valid?(name: "Foo", _rules: [id: [presence: true]])
    end

    test "record, included presence validation" do
        assert Blueprint.valid?(%RecordTest{name: "I have a name"})
    end
end
