defmodule SchemaRulesTest do
    use ExUnit.Case

    defmodule Typed do
        use Blueprint.Schema

        @mapping [
            name:   [:string, length: [min: 2, max: 10]],
            value:  [:integer, required: false]
        ]

        schema do
            field :name,    :string,  length: [min: 2, max: 20], pattern: :email
            field :one,     :map,     fields: @mapping
            field :nested,  Typed,    required: true
            field :struct,  Typed,    struct: Typed
            field :many,    :list,    type: {:map, fields: @mapping}
        end

    end

    describe "SchemaRules" do
        @tag :schema_rules
        test "schema_rules, should cast nested maps" do
            one = %{name: 122345, value: "138"}
            many = %{name: 12, value: "138"}
            nested = %{}
            typed = %{
                one: one, 
                name: "sample@live.com", 
                nested: nested, 
                many: List.wrap(many)
            }

            casted = Typed.new(typed)

            assert {:error, [{:struct, _}]} =
                casted
                |> Blueprint.validate()

            {:ok, dumped} =
                casted
                |> Typed.dump()

            assert {:ok, ^casted} =
                dumped
                |> Typed.cast()

        end
    end

end




