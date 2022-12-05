defmodule FleetBot.Fleetyards.ModelsTest do
  use ExUnit.Case, async: true
  import Tesla.Mock
  doctest FleetBot.Fleetyards.Models, import: true

  setup do
    mock_global(fn
      %{method: :get, url: "https://api.example.org/v1/models/slugs"} ->
        json(["msr", "600i-touring"])

      %{method: :get, url: "https://api.example.org/v1/models/600i-touring"} ->
        json(%{"slug" => "600i-touring", "name" => "600i Touring"})
    end)

    :ok
  end
end
