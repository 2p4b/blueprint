defmodule UUIDTest do
    use ExUnit.Case

    @tag :uuid
    test "uuid, should cast uuid value" do
        sample = UUID.uuid1()
        assert {:ok, ^sample} = 
            sample
            |> Blueprint.Types.UUID.cast([])
    end

    test "uuid, should not cast invalid uuid values" do
        assert {:error, _reason} = 
            "xxx-xxx-xxx-xxx"
            |> Blueprint.Types.UUID.cast([])
    end

end


