defmodule FleetBotTest do
  use ExUnit.Case
  doctest FleetBot

  test "greets the world" do
    assert FleetBot.hello() == :world
  end
end
