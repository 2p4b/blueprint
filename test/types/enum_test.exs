defmodule EnumTest do
    use ExUnit.Case

    describe "Draft.Type.Enum" do
      @tag :enum
      test "enum, should cast value" do
          assert {:ok, 2} = 
              "2"
              |> Draft.Type.Enum.cast(values: [2, 4, 6])

          assert {:ok, :test} = 
              "test"
              |> Draft.Type.Enum.cast(values: [:test, :enum])

          assert {:ok, "enum"} = 
              :enum
              |> Draft.Type.Enum.cast(values: ["enum"])

      end

      @tag :enum
      test "enum, should not cast invalid enum value" do
          assert {:error, _reason} = 
              "four"
              |> Draft.Type.Enum.cast(values: ["one", "two"])
      end
    end

end



