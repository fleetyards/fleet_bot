defmodule FleetBot.Application do
  @moduledoc false
  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      FleetBot.Repo,
      FleetBot.Discord.Commands,
      FleetBot.Discord,
      FleetBot.Fleetyards.Supervisor,
      {TelemetryMetricsAppsignal, [metrics: metrics()]}
    ]

    opts = [strategy: :one_for_one, name: FleetBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  import Telemetry.Metrics

  defp metrics do
    [
      summary([:fleet_bot, :discord, :handle_event, :interaction, :stop, :duration],
        tags: [:command],
        unit: {:native, :second}
      ),

      # Fleetyards
      ## Cache
      summary([:fleet_bot, :fleetyards, :cache, :command, :stop, :duration],
        unit: {:native, :second}
      )
      # counter([:fleet_bot, :fleetyards, :cache, :command, :stop, :duration])
    ]
  end
end
