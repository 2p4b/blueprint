defmodule InclusionTest do
    use ExUnit.Case

    @tag :inclusion
    test "keyword list, provided inclusion validation with a list without in keyword" do
        assert Blueprint.valid?([category: :cows], category: [inclusion: [:cows, :pigs]])
        assert !Blueprint.valid?([category: :cats], category: [inclusion: [:cows, :pigs]])
    end

    @tag :inclusion
    test "keyword list, provided inclusion validation with a list" do
        assert Blueprint.valid?([category: :cows], category: [inclusion: [in: [:cows, :pigs]]])
        assert !Blueprint.valid?([category: :cats], category: [inclusion: [in: [:cows, :pigs]]])
    end
end
