defmodule FloatTest do
    use ExUnit.Case

    describe "Draft.Type.Float" do
        @tag :float
        test "float, should cast float value" do
            assert {:ok, 0.99} = 
                0.99
                |> Draft.Type.Float.cast([])

        end

        @tag :float
        test "float, should parse float value" do
            assert {:ok, 3.14} = 
                "3.14"
                |> Draft.Type.Float.cast([])
        end

        @tag :float
        test "float, should not cast non valid float values" do
            assert {:error, _reason} = 
                "0.9.9"
                |> Draft.Type.Float.cast([])

            assert {:error, _reason} = 
                ".0923"
                |> Draft.Type.Float.cast([])

            assert {:error, _reason} = 
                []
                |> Draft.Type.Float.cast([])

            assert {:error, _reason} = 
                %{}
                |> Draft.Type.Float.cast([])
        end
    end

end


