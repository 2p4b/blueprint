defmodule DocTest do
    use ExUnit.Case

    describe "Doctest" do
        @tag :string
        doctest Draft.Type.String

        @tag :datetime
        doctest Draft.Type.Datetime

        @tag :exclusion
        doctest Draft.Validator.Exclusion

        @tag :format
        doctest Draft.Validator.Format
    end

end
