defmodule EnumTest do
    use ExUnit.Case

    @tag :enum
    test "enum, should cast value" do
        assert {:ok, 2} = 
            "2"
            |> Blueprint.Type.Enum.cast([2, 4, 6])

        assert {:ok, :test} = 
            "test"
            |> Blueprint.Type.Enum.cast([:test, :enum])

        assert {:ok, "enum"} = 
            :enum
            |> Blueprint.Type.Enum.cast(["enum"])

    end

    @tag :enum
    test "enum, should not cast invalid enum value" do
        assert {:error, _reason} = 
            "four"
            |> Blueprint.Type.Enum.cast(["one", "two"])
    end

end



