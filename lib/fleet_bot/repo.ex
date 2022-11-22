defmodule FleetBot.Repo do
  use Ecto.Repo,
    otp_app: :fleet_bot,
    adapter: Ecto.Adapters.Postgres
end
