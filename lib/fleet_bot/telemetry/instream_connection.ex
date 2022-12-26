defmodule FleetBot.Telemetry.InstreamConnection do
  use Instream.Connection, otp_app: :fleet_bot

  @moduledoc false

  @doc false
  def start_instream? do
    config(:enabled)
  end

  def load_config() do
    Application.put_env(
      :fleet_bot,
      __MODULE__,
      Application.fetch_env!(:fleet_bot, FleetBot.Telemetry)
    )
  end
end
