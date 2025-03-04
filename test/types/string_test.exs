defmodule StringTest do
    use ExUnit.Case

    describe "Draft.Type.String" do
        @tag :string
        test "string, should cast string value" do
            assert {:ok, "hi hello"} = 
                "hi hello"
                |> Draft.Type.String.cast([])

            assert {:ok, "100"} = 
                100
                |> Draft.Type.String.cast([])

            assert {:ok, "100"} = 
                100
                |> Draft.Type.String.cast([])
        end

        test "string, should not cast values with not String.Chars protocol" do
            assert {:error, _reason} = 
                []
                |> Draft.Type.String.cast([])

            assert {:error, _reason} = 
                %{}
                |> Draft.Type.String.cast([])

        end
    end

end


