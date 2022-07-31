defmodule StringTest do
    use ExUnit.Case

    @tag :string
    test "string, should cast string value" do
        assert {:ok, "hi hello"} = 
            "hi hello"
            |> Blueprint.Types.String.cast([])

        assert {:ok, "100"} = 
            100
            |> Blueprint.Types.String.cast([])

        assert {:ok, "100"} = 
            100
            |> Blueprint.Types.String.cast([])
    end

    test "string, should not cast values with not String.Chars protocol" do
        assert {:error, _reason} = 
            []
            |> Blueprint.Types.String.cast([])

        assert {:error, _reason} = 
            %{}
            |> Blueprint.Types.String.cast([])

    end

end


