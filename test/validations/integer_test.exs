defmodule IntegerTest do
    use ExUnit.Case

    @tag :float
    test "float validation" do
        assert Blueprint.valid?(1, integer: true)
        assert !Blueprint.valid?(1.34, integer: true)
    end
end
