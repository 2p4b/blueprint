defmodule InheirtanceTest do
    use ExUnit.Case

    defmodule Super do
        use Blueprint.Schema
        schema required: true do
            field :value, :number, default: 1
        end
    end

    defmodule Base do
        use Blueprint.Schema
        schema extends: Super do
            field :name, :string, default: "name"
        end
    end

    defmodule Child do
        use Blueprint.Schema
        schema extends: [Base, Super]
    end

    describe "Inheritance" do
        @tag :inherite
        test "should inherite base struct fields" do
            assert %Child{} |> Map.from_struct() |> Map.keys() |> length() == 2
        end

        @tag :inherite
        test "should inherite defaults" do
            child = Child.new([])
            assert child.value === 1
            assert child.name === "name"
        end
    end

end





