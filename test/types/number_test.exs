defmodule NumberTest do
    use ExUnit.Case

    describe "Draft.Type.Number" do
        @tag :number
        test "number, should cast number value" do
            assert {:ok, 0.99} = 
                0.99
                |> Draft.Type.Number.cast([])

            assert {:ok, 99} = 
                "99"
                |> Draft.Type.Number.cast([])

        end

        @tag :number
        test "number, should parse number value" do

            assert {:ok, 99} = 
                "99"
                |> Draft.Type.Number.cast([])

            assert {:ok, 3.14} = 
                "3.14"
                |> Draft.Type.Number.cast([])
        end

        @tag :number
        test "number, should not cast non valid numeric values" do
            assert {:error, _reason} = 
                ".0923"
                |> Draft.Type.Number.cast([])

            assert {:error, _reason} = 
                []
                |> Draft.Type.Number.cast([])

            assert {:error, _reason} = 
                %{}
                |> Draft.Type.Number.cast([])
        end
    end

end


