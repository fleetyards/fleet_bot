defmodule FleetBot.Application do
  @moduledoc false
  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      # Telemetry
      FleetBot.Telemetry,

      # Repo
      FleetBot.Repo,

      # Discord
      FleetBot.Discord.Commands,
      FleetBot.Discord,

      # Fleetyards
      FleetBot.Fleetyards.Supervisor
    ]

    opts = [strategy: :one_for_one, name: FleetBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
