defmodule FleetBot.Telemetry.InstreamBufferedWritter do
  @moduledoc """
  Buffered write adapter for an Instream connection
  """
  use GenServer
  @behaviour TelemetryMetricsTelegraf.Writer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) when is_list(opts) do
    reset_timer()

    {:ok,
     %{
       connection: Keyword.get(opts, :connection, FleetBot.Telemetry.InstreamConnection),
       log: Keyword.get(opts, :log, FleetBot.Telemetry.InstreamConnection.config(:log))
     }}
  end

  @impl true
  def init(opts) when is_map(opts) do
    {:ok, opts}
  end

  @impl TelemetryMetricsTelegraf.Writer
  def write(measurement_name, tags, fields, opts) do
    GenServer.cast(__MODULE__, {:write, measurement_name, tags, fields, opts})
  end

  def get do
    GenServer.call(__MODULE__, :get)
  end

  def count do
    GenServer.call(__MODULE__, :get_count)
  end

  def flush do
    reset_timer(0)
  end

  # Server Callbacks
  @impl GenServer
  def handle_call(:get, _from, %{cache: cache} = state) do
    {:reply, cache, state}
  end

  @impl GenServer
  def handle_call(:get_count, _from, %{cache: cache} = state) do
    {:reply, Enum.count(cache), state}
  end

  @impl GenServer
  def handle_cast({:write, name, tags, fields, _opts}, state) do
    elem = %{
      measurement: name,
      tags: Map.merge(tags, %{otp_app: state.connection.config(:otp_app), node: Node.self()}),
      fields: fields,
      timestamp: DateTime.utc_now() |> DateTime.to_unix(:nanosecond)
    }

    state =
      state
      |> Map.update(:cache, [], fn cache ->
        new = [elem | cache]

        if Enum.count(new) > 500 do
          reset_timer(0)
        end

        new
      end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:write, state) do
    {points, state} = Map.pop(state, :cache, [])

    state.connection.write(points,
      log: Map.get(state, log: Map.get(state, :log, false))
    )

    reset_timer()

    {:noreply, state}
  end

  defp reset_timer(time \\ 30_000) do
    Process.send_after(__MODULE__, :write, time)
  end
end
