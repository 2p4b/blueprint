defmodule ArrayTest do
    use ExUnit.Case

    @tag :array
    test "array, should cast array values" do
        assert {:ok, [1, 2, 3]} = 
            [1, 2, 3]
            |> Blueprint.Types.Array.cast(type: {:integer, []})

        assert {:ok, [true, true, true, true]} = 
            ["1", 1, true, "true"]
            |> Blueprint.Types.Array.cast(type: :boolean)
    end

    @tag :array
    test "array, should cast array enum value type" do
        assert {:ok, [1, :one, 1, :one, "two"]} = 
            ["1", "one", 1, "one", "two"]
            |> Blueprint.Types.Array.cast(type: {:enum, [1, :one, "two"]})
    end

    @tag :array
    test "array, should not cast invalid array value type" do
        assert {:error, [{1, _errror}]} = 
            [UUID.uuid1(), "invaliduuid"]
            |> Blueprint.Types.Array.cast(type: :uuid)
    end

end



