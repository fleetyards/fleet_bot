defmodule FleetBot.FleetyardsTest do
  use ExUnit.Case
  import Tesla.Mock
  doctest FleetBot.Fleetyards, import: true

  setup do
    mock(fn
      %{method: :get, url: "https://api.example.org/v1/version"} ->
        json(%{"codename" => "Odyssey", "version" => "v5.11.4"})
    end)

    :ok
  end
end
