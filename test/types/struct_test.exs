defmodule StructTest do
    use ExUnit.Case

    defmodule Nested do
        use Blueprint.Struct
        
        schema do
            field :name, :string, presence: true
            field :value, :number
        end
    end

    defmodule Typed do
        use Blueprint.Struct

        @mapping [
            name:   [:string, length: [min: 5, max: 10]],
            value:  [:number, required: false]
        ]

        schema do
            field :map_type, :map,  fields: @mapping
            field :name, :string,   default: "my name"
            field :nested, Nested,  default: nil
            field :array_test, :array, type: Nested,  default: []
        end

    end

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



