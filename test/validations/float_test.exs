defmodule FloatTest do
    use ExUnit.Case

    @tag :float
    test "float validation" do
        assert Blueprint.valid?(1.2, float: true)
        assert !Blueprint.valid?(1, float: true)
    end
end
