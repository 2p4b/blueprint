defmodule BooleanTest do
    use ExUnit.Case

    @tag :boolean
    test "boolean, should cast boolean value" do
        assert {:ok, true} = 
            "true"
            |> Blueprint.Types.Boolean.cast([])

        assert {:ok, true} = 
            1
            |> Blueprint.Types.Boolean.cast([])

        assert {:ok, false} = 
            0
            |> Blueprint.Types.Boolean.cast([])
    end

    test "boolean, should not cast invalid truthy values" do
        assert {:error, _reason} = 
            "none"
            |> Blueprint.Types.Boolean.cast([])
    end

end


