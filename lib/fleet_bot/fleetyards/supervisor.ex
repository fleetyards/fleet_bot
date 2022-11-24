defmodule FleetBot.Fleetyards.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(_opts) do
    children = [
      FleetBot.Fleetyards.Cache,
      {Task.Supervisor, name: FleetBot.Fleetyards.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
