defmodule NumberTest do
    use ExUnit.Case

    @tag :number
    test "number, should cast number value" do
        assert {:ok, 0.99} = 
            0.99
            |> Blueprint.Types.Number.cast([])

        assert {:ok, 99} = 
            "99"
            |> Blueprint.Types.Number.cast([])

    end

    @tag :number
    test "number, should parse number value" do

        assert {:ok, 99} = 
            "99"
            |> Blueprint.Types.Number.cast([])

        assert {:ok, 3.14} = 
            "3.14"
            |> Blueprint.Types.Number.cast([])
    end

    @tag :number
    test "number, should not cast non valid numeric values" do
        assert {:error, _reason} = 
            ".0923"
            |> Blueprint.Types.Number.cast([])

        assert {:error, _reason} = 
            []
            |> Blueprint.Types.Number.cast([])

        assert {:error, _reason} = 
            %{}
            |> Blueprint.Types.Number.cast([])
    end

end


