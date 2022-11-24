defmodule FleetBot.Fleetyards.Cache do
  use Nebulex.Cache,
    otp_app: :fleet_bot,
    # Maybe update to cluster storage once libcluster is used
    adapter: Nebulex.Adapters.Local

  def match_non_error({:error, _}), do: false
  def match_non_error({:error}), do: false
  def match_non_error(:error), do: false
  def match_non_error(nil), do: false
  def match_non_error([]), do: false
  def match_non_error(_), do: true
end
