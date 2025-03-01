defmodule BlueprintTest do
    use ExUnit.Case

    describe "Blueprint" do

        @tag :validate_required
        test "validate_required/2" do
            sample = %{one: 1, two: 2, three: 3}
            assert {:ok, _attr} = 
                sample 
                |> Blueprint.validate_required([:one, :two, :three])

            assert {:error, :four} = 
                sample 
                |> Blueprint.validate_required([:one, :two, :three, :four])
        end

    end

end

