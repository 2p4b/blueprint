defmodule DocTest do
    use ExUnit.Case

    describe "Doctest" do
        @tag :string
        doctest Blueprint.Type.String

        @tag :datetime
        doctest Blueprint.Type.Datetime

        @tag :exclusion
        doctest Blueprint.Validator.Exclusion

        @tag :format
        doctest Blueprint.Validator.Format
    end

end
