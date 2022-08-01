defmodule MapTest do
    use ExUnit.Case

    @tag :map
    test "map, should cast map field values" do
        fields = [one: :number, two: :float, valid: :boolean]
        assert {:ok, %{one: 1, valid: true, two: 3.14}} = 
            %{one: 1, valid: "true", two: "3.14"}
            |> Blueprint.Type.Map.cast(fields: fields)
    end

    @tag :map
    test "map, should cast nested maps" do
        schema = [
            one: {:map, fields: [
                date: :datetime, 
                two: {:map, fields: [
                    three: :string
                ]}
            ]}
        ]

        data = %{
            one: %{
                "date" => "1800-01-01",
                "two" => %{three: 3}
            }
        }

        valid = %{
            one: %{
                two: %{three: "3"},
                date: ~N[1800-01-01 00:00:00], 
            }
        }

        assert {:ok, ^valid} = 
            data
            |> Blueprint.Type.Map.cast(fields: schema)
    end

    @tag :map
    test "map, should cast map field keys" do
        fields = [one: :number, two: :float, valid: :boolean] 
        assert {:ok, %{one: 1, valid: true, two: 3.14}} = 
            %{"one" => 1, "valid" => "true", "two" => "3.14"}
            |> Blueprint.Type.Map.cast(fields: fields)
    end

    @tag :map
    test "map, should cast not cast invalid fields" do
        fields = [one: :number, two: :integer, valid: :boolean]
        assert {:error, errors} = 
            %{"one" => 1, "valid" => "invalid", "two" => "3.14"}
            |> Blueprint.Type.Map.cast(fields: fields)

        assert %{valid: _, two: _} = Enum.into(errors, %{})
    end


end



