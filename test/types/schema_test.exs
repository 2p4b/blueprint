defmodule SchemaTest do
    use ExUnit.Case

    defmodule Nested do
        use Draft.Schema
        
        schema do
            field :name, :string, presence: true
            field :value, :number
        end
    end

    defmodule Typed do
        use Draft.Schema

        @mapping [
            name:   [:string, length: [min: 5, max: 10]],
            value:  [:number, required: false]
        ]

        schema do
            field :map_type, :map,  fields: @mapping
            field :name, :string,   default: "my name"
            field :nested, Nested,  default: nil
            field :array_test, :list, type: Nested,  default: []
        end

    end

    defmodule Source do
        defstruct [:name, :value, :extra]
    end

    defmodule SourceMissingRequired do
        defstruct [:extra]
    end

    defmodule Target do
        use Draft.Schema

        schema do
            field :name, :string, required: true
            field :value, :number
        end
    end

    defmodule TargetWithRemap do
        use Draft.Schema

        schema do
            field :title, :string
            field :count, :number
        end
    end

    describe "Schema" do
        @tag :struct
        test "struct, should cast struct" do
            nested = %{name: "when", value: "189"}
            cast_nested = %Nested{name: "when", value: 189}

            assert %Typed{
                name: nil,
                map_type: Map.from_struct(cast_nested),
                nested: cast_nested,
                array_test: [cast_nested]
            } ==
                %{
                    name: nil,
                    nested: nested,
                    map_type: nested,
                    array_test: List.wrap(nested)
                }
                |> Typed.new()
        end
    end

    describe "from_struct/2" do
        @tag :from_struct
        test "returns struct directly on successful cast" do
            source = %Source{name: "test", value: "123", extra: "ignored"}
            result = Target.from_struct(source)

            assert %Target{} = result
            assert result.name == "test"
            assert result.value == 123
        end

        @tag :from_struct
        test "handles remap option to rename fields" do
            source = %Source{name: "title value", value: "42", extra: "ignored"}
            result = TargetWithRemap.from_struct(source, title: :name, count: :value)

            assert %TargetWithRemap{} = result
            assert result.title == "title value"
            assert result.count == 42
        end

        @tag :from_struct
        test "returns error tuple when required field is missing" do
            source = %SourceMissingRequired{extra: "ignored"}
            result = Target.from_struct(source)

            assert {:error, _} = result
        end

        @tag :from_struct
        test "ignores extra fields from source struct" do
            source = %Source{name: "test", value: "99", extra: "this should be ignored"}
            result = Target.from_struct(source)

            assert %Target{} = result
            refute Map.has_key?(Map.from_struct(result), :extra)
        end
    end


end



