defmodule FormatTest do
    use ExUnit.Case

    @tag :format
    test "keyword list, provided format validation" do
        assert Blueprint.valid?([component: "x1234"], component: [format: [with: ~r/(^x\d+$)/]])
        assert !Blueprint.valid?([component: "d1234"], component: [format: [with: ~r/(^x\d+$)/]])
        assert !Blueprint.valid?([component: nil], component: [format: [with: ~r/(^x\d+$)/]])
    end

    @tag :format
    test "custom error messages" do
        assert Blueprint.errors([component: "will not match"],
                component: [format: [with: ~r/foo/, message: "Custom!"]]
            ) == [{:error, :component, :format, "Custom!"}]

        assert Blueprint.errors([component: "will not match"],
                component: [
                format: [
                    with: ~r/foo/,
                    message: "'<%= value %>' doesn't match <%= inspect pattern %>"
                ]
                ]
            ) == [{:error, :component, :format, "'will not match' doesn't match ~r/foo/"}]
    end

end
