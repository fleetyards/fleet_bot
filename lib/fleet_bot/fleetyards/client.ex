defmodule FleetBot.Fleetyards.Client do
  @moduledoc """
  Tesla HTTP client used for fleetyards api.
  """
  use Tesla

  plug Tesla.Middleware.Logger, log_level: &my_log_level/1, filter_headers: ["authorization"]
  plug Tesla.Middleware.BaseUrl, Application.fetch_env!(:fleet_bot, FleetBot.Fleetyards)[:api_url]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Headers, [{"user-agent", get_user_agent_header()}]
  plug FleetBot.Fleetyards.Tesla.DecodeFleetyardsPagination

  def new(token) do
    middleware = [{Tesla.Middleware.BearerAuth, :call, [[token: token]]} | __middleware__()]
    %Tesla.Client{pre: middleware, post: []}
  end

  def new() do
    %Tesla.Client{pre: __middleware__(), post: []}
  end

  def middlewares do
    @__middleware__
  end

  ## Plug helpers
  def get_user_agent_header do
    [
      "FleetBot/#{get_version()}",
      "(#{:erlang.system_info(:system_architecture)}) OTP/#{:erlang.system_info(:otp_release)} (#{String.trim(:binary.list_to_bin(:erlang.system_info(:system_version)))}) ",
      "Tesla/#{get_version(:tesla)}"
    ]
    |> Enum.join(" ")
  end

  def get_version(app \\ :fleet_bot) do
    Application.spec(app)[:vsn]
  end

  def my_log_level(env) do
    case env.status do
      404 -> :info
      _ -> :default
    end
  end
end
