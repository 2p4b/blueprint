defmodule BlueprintTest do
  use ExUnit.Case
  doctest Blueprint

  test "greets the world" do
    assert Blueprint.hello() == :world
  end
end
