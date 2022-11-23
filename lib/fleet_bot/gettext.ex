defmodule FleetBot.Gettext do
  use Gettext, otp_app: :fleet_bot

  defmacro debug(msg, opts \\ []) do
    quote do
      Logger.debug(FleetBot.Gettext.dgettext("logger", unquote(msg), unquote(opts)))
    end
  end

  defmacro info(msg, opts \\ []) do
    quote do
      Logger.info(FleetBot.Gettext.dgettext("logger", unquote(msg), unquote(opts)))
    end
  end

  defmacro __using__(_opts) do
    quote do
      alias unquote(__MODULE__), as: LGettext
      require unquote(__MODULE__)
      require Logger
    end
  end
end
