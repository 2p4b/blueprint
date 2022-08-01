defmodule IntegerTest do
    use ExUnit.Case

    @tag :integer
    test "integer, should cast number value" do
        assert {:ok, 99} = 
            99
            |> Blueprint.Type.Integer.cast([])
    end

    @tag :integer
    test "integer, should parse number value" do

        assert {:ok, 99} = 
            "99"
            |> Blueprint.Type.Integer.cast([])
    end

    @tag :integer
    test "integer, should not cast non valid numeric values" do
        assert {:error, _reason} = 
            "0.923"
            |> Blueprint.Type.Integer.cast([])

        assert {:error, _reason} = 
            []
            |> Blueprint.Type.Integer.cast([])

        assert {:error, _reason} = 
            %{}
            |> Blueprint.Type.Integer.cast([])
    end

end


