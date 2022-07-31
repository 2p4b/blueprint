defmodule AtomTest do
    use ExUnit.Case

    @tag :atom
    test "atom, should cast atom value" do
        assert {:ok, :yes} = 
            :yes
            |> Blueprint.Types.Atom.cast([])

        assert {:ok, :yes} = 
            "yes"
            |> Blueprint.Types.Atom.cast([])
    end

    @tag :atom
    test "atom, should not cast invalid atom values" do
        assert {:error, _reason} = 
            UUID.uuid1()
            |> Blueprint.Types.Atom.cast([])
    end

end



