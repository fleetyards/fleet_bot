defmodule FleetBot.Application do
  @moduledoc false
  use Application

  @impl Application
  def start(_type, _args) do
    children = [
      FleetBot.Repo,
      FleetBot.Discord.Commands,
      FleetBot.Discord
    ]

    # TODO: use stragety :rest_for_one?
    opts = [strategy: :one_for_one, name: FleetBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
