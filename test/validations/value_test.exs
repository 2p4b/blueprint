defmodule ValueTest do
    use ExUnit.Case

    @tag :value
    test "field value value test" do
        value = ValueStruct.new(value: 1)
        assert Blueprint.valid?(value)
    end

end

