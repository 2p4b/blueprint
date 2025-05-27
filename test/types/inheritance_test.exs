defmodule InheirtanceTest do
    use ExUnit.Case

    defmodule Super do
        use Draft.Schema
        schema required: true do
            field :value, :number, default: 1
        end
    end

    defmodule Base do
        use Draft.Schema
        schema extends: Super do
            field :name, :string, default: "name"
        end
    end

    defmodule Child do
        use Draft.Schema
        schema extends: [Base, Super]
    end

    describe "Inheritance" do

        @tag :inherite
        test "should inherite base struct fields" do
            object = %Child{} |> Map.from_struct() 
            keys = Map.keys(object)
            assert length(keys) == 2
            assert :name in keys
            assert :value in keys
        end

        @tag :inherite
        test "should inherite defaults" do
            child = Child.new([])
            assert child.value === 1
            assert child.name === "name"
        end
    end

end





