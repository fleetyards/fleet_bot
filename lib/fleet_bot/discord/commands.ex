defmodule FleetBot.Discord.Commands do
  use Supervisor

  def get_commands,
    do: [
      FleetBot.Discord.Fleetyards
    ]

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl Supervisor
  def init(_opts) do
    children =
      [
        FleetBot.Discord.Commands.RegisterManager
      ] ++ get_supervised_commands()

    Supervisor.init(children, strategy: :one_for_one)
  end

  def get_supervised_commands(commands \\ get_commands()) do
    commands
    |> Enum.filter(&Kernel.function_exported?(&1, :start_link, 1))
    |> Enum.into([])
  end
end
