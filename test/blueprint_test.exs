defmodule BlueprintTest do
    use ExUnit.Case

    describe "Draft" do

        @tag :validate_required
        test "validate_required/2" do
            sample = %{one: 1, two: 2, three: 3}
            assert {:ok, _attr} = 
                sample 
                |> Draft.validate_required([:one, :two, :three])

            assert {:error, :four} = 
                sample 
                |> Draft.validate_required([:one, :two, :three, :four])
        end

    end

end

