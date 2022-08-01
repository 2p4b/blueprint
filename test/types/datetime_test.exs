defmodule DatetimeTest do
    use ExUnit.Case

    @tag :datetime
    test "datetime, should cast datetime value" do
        assert {:ok, _value} = 
            "01-01-1900"
            |> Blueprint.Type.Datetime.cast([])

        assert {:ok, _value} = 
            "1900-01-01"
            |> Blueprint.Type.Datetime.cast([])

        assert {:ok, _value} = 
            "2016-02-29T22:25:00-06:00"
            |> Blueprint.Type.Datetime.cast([])

    end

    @tag :datetime
    test "datetime, should not cast invalid value" do
        assert {:error, _value} = 
            "01-01-19a0"
            |> Blueprint.Type.Datetime.cast([])

        assert {:error, _value} = 
            "1900-81-01"
            |> Blueprint.Type.Datetime.cast([])

        assert {:error, _value} = 
            "2016-02-29T22:2:00-06:00"
            |> Blueprint.Type.Datetime.cast([])
    end

end



