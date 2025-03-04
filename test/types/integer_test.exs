defmodule IntegerTest do
    use ExUnit.Case

    describe "Draft.Type.Integer" do
        @tag :integer
        test "integer, should cast number value" do
            assert {:ok, 99} = 
                99
                |> Draft.Type.Integer.cast([])
        end

        @tag :integer
        test "integer, should parse number value" do

            assert {:ok, 99} = 
                "99"
                |> Draft.Type.Integer.cast([])
        end

        @tag :integer
        test "integer, should not cast non valid numeric values" do
            assert {:error, _reason} = 
                "0.923"
                |> Draft.Type.Integer.cast([])

            assert {:error, _reason} = 
                []
                |> Draft.Type.Integer.cast([])

            assert {:error, _reason} = 
                %{}
                |> Draft.Type.Integer.cast([])
        end
    end

end


