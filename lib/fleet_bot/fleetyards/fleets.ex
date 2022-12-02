defmodule FleetBot.Fleetyards.Fleets do
  alias FleetBot.Fleetyards
  use FleetBot.Fleetyards
  use Nebulex.Caching

  def info(fleet) when is_binary(fleet) do
    Client.get("/v1/fleets/#{fleet}")
    |> match_error
  end

  def public(fleet, query \\ %{}) when is_binary(fleet) do
    Client.get("/v1/fleets/#{fleet}/public-vehicles", query: query)
    |> match_error
  end
end
