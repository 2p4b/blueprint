defmodule BooleanTest do
    use ExUnit.Case

    describe "Draft.Type.Boolean" do
        @tag :boolean
        test "boolean, should cast boolean value" do
            assert {:ok, true} = 
                "true"
                |> Draft.Type.Boolean.cast([])

            assert {:ok, true} = 
                1
                |> Draft.Type.Boolean.cast([])

            assert {:ok, false} = 
                0
                |> Draft.Type.Boolean.cast([])
        end

        test "boolean, should not cast invalid truthy values" do
            assert {:error, _reason} = 
                "none"
                |> Draft.Type.Boolean.cast([])
        end
    end

end


