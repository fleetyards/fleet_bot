defmodule FleetBot.Fleetyards.Fleets do
  alias FleetBot.Fleetyards
  use FleetBot.Fleetyards
  use Nebulex.Caching

  @doc """
  Get Fleet info

  ## Example

    iex> info("test-fleet")
    {:ok, %{"name" => "Test Fleet", "slug" => "test-fleet"}}
  """
  def info(fleet) when is_binary(fleet) do
    Client.get("/v1/fleets/#{fleet}")
    |> unpack_body
  end

  def public(fleet, query \\ %{}) when is_binary(fleet) do
    Client.get("/v1/fleets/#{fleet}/public-vehicles", query: query)
    |> unpack_body
  end
end
