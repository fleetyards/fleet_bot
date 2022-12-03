defmodule FleetBot.Fleetyards.VehiclesTest do
  use ExUnit.Case
  import Tesla.Mock
  doctest FleetBot.Fleetyards.Vehicles, import: true

  setup do
    mock(fn
      %{method: :get, url: "https://api.example.org/v1/hangar-groups/no_groups"} ->
        json([])

      %{method: :get, url: "https://api.example.org/v1/hangar-groups/groups"} ->
        json([
          %{
            "color" => "#2980B9",
            "id" => "0fe3d750-9242-40fc-b514-3929791ad575",
            "name" => "Group 1",
            "public" => true,
            "slug" => "grp1",
            "sort" => 0,
            "vehiclesCount" => 1
          },
          %{
            "color" => "#C0382B",
            "id" => "1610f56d-2ab3-4fed-a715-586525f80793",
            "name" => "main",
            "public" => true,
            "slug" => "main",
            "sort" => 1,
            "vehiclesCount" => 2
          }
        ])
    end)

    :ok
  end
end
