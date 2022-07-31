defmodule EnumTest do
    use ExUnit.Case

    @tag :enum
    test "enum, should cast value" do
        assert {:ok, 2} = 
            "2"
            |> Blueprint.Types.Enum.cast([2, 4, 6])

        assert {:ok, :test} = 
            "test"
            |> Blueprint.Types.Enum.cast([:test, :enum])

        assert {:ok, "enum"} = 
            :enum
            |> Blueprint.Types.Enum.cast(["enum"])

    end

    @tag :enum
    test "enum, should not cast invalid enum value" do
        assert {:error, _reason} = 
            "four"
            |> Blueprint.Types.Enum.cast(["one", "two"])
    end

end



