defmodule AtomTest do
    use ExUnit.Case

    describe "Draft.Type.Atom" do
        @tag :atom
        test "atom, should cast atom value" do
            assert {:ok, :yes} = 
                :yes
                |> Draft.Type.Atom.cast([])

            assert {:ok, :yes} = 
                "yes"
                |> Draft.Type.Atom.cast([])
        end

        @tag :atom
        test "atom, should not cast invalid atom values" do
            assert {:error, _reason} = 
                UUID.uuid1()
                |> Draft.Type.Atom.cast([])
        end
    end

end



