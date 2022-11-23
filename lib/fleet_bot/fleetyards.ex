defmodule FleetBot.Fleetyards do
  # do: {"Authorization", "Bearer " <> token}
  def get_auth_header(token), do: {""}

  defmacro __using__(_opts) do
    quote do
      @backend Application.compile_env(:fleet_bot, [FleetBot.Fleetyards, :client])
      import unquote(__MODULE__), only: [get_auth_header: 1]
    end
  end
end
