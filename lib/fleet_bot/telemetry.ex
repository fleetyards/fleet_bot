defmodule FleetBot.Telemetry do
  @moduledoc false
  use Supervisor
  import Telemetry.Metrics

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl Supervisor
  def init(_arg) do
    FleetBot.Telemetry.InstreamConnection.load_config()

    children =
      [
        # Telemetry poller will execute the given period measurements
        # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
        {:telemetry_poller, measurements: periodic_measurements(), period: 10_000},
        # Add reporters as children of your supervision tree.
        # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
        {TelemetryMetricsAppsignal, [metrics: metrics()]}
      ] ++ influx_childs()

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc false
  def influx_childs do
    if FleetBot.Telemetry.InstreamConnection.start_instream?() do
      [
        FleetBot.Telemetry.InstreamConnection,
        FleetBot.Telemetry.InstreamBufferedWritter,
        {TelemetryMetricsTelegraf,
         metrics: metrics(), adapter: FleetBot.Telemetry.InstreamBufferedWritter}
      ]
    else
      []
    end
  end

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
      ),
      # counter([:fleet_bot, :fleetyards, :cache, :command, :stop, :duration])

      # Database Metrics
      summary("fleet_bot.repo.query.total_time",
        unit: {:native, :millisecond},
        description: "The sum of the other measurements"
      ),
      summary("fleet_bot.repo.query.decode_time",
        unit: {:native, :millisecond},
        description: "The time spent decoding the data received from the database"
      ),
      summary("fleet_bot.repo.query.query_time",
        unit: {:native, :millisecond},
        description: "The time spent executing the query"
      ),
      summary("fleet_bot.repo.query.queue_time",
        unit: {:native, :millisecond},
        description: "The time spent waiting for a database connection"
      ),
      summary("fleet_bot.repo.query.idle_time",
        unit: {:native, :millisecond},
        description:
          "The time the connection spent waiting before being checked out for the query"
      ),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.memory.processes", unit: {:byte, :kilobyte}),
      summary("vm.memory.processes_used", unit: {:byte, :kilobyte}),
      summary("vm.memory.system", unit: {:byte, :kilobyte}),
      summary("vm.memory.atom", unit: {:byte, :kilobyte}),
      summary("vm.memory.atom_used", unit: {:byte, :kilobyte}),
      summary("vm.memory.binary", unit: {:byte, :kilobyte}),
      summary("vm.memory.code", unit: {:byte, :kilobyte}),
      summary("vm.memory.ets", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),
      summary("vm.system_counts.process_count"),
      summary("vm.system_counts.atom_count"),
      summary("vm.system_counts.port_count")
    ]
  end

  defp periodic_measurements do
    []
  end
end
