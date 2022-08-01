defmodule FloatTest do
    use ExUnit.Case

    @tag :float
    test "float, should cast float value" do
        assert {:ok, 0.99} = 
            0.99
            |> Blueprint.Type.Float.cast([])

    end

    @tag :float
    test "float, should parse float value" do
        assert {:ok, 3.14} = 
            "3.14"
            |> Blueprint.Type.Float.cast([])
    end

    @tag :float
    test "float, should not cast non valid float values" do
        assert {:error, _reason} = 
            "0.9.9"
            |> Blueprint.Type.Float.cast([])

        assert {:error, _reason} = 
            ".0923"
            |> Blueprint.Type.Float.cast([])

        assert {:error, _reason} = 
            []
            |> Blueprint.Type.Float.cast([])

        assert {:error, _reason} = 
            %{}
            |> Blueprint.Type.Float.cast([])
    end

end


