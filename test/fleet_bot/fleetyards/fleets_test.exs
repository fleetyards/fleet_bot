defmodule FleetBot.Fleetyards.FleetsTest do
  use ExUnit.Case, async: true
  import Tesla.Mock

  doctest FleetBot.Fleetyards.Fleets, import: true

  setup do
    mock(fn
      %{method: :get, url: "https://api.example.org/v1/fleets/test-fleet"} ->
        json(%{"name" => "Test Fleet", "slug" => "test-fleet"})
    end)
  end
end
