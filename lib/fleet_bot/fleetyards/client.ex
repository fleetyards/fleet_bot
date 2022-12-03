defmodule FleetBot.Fleetyards.Client do
  use Tesla

  plug Tesla.Middleware.Logger, log_level: &my_log_level/1, filter_headers: ["authorization"]
  plug Tesla.Middleware.BaseUrl, Application.fetch_env!(:fleet_bot, FleetBot.Fleetyards)[:api_url]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Headers, [{"user-agent", get_user_agent_header()}]
  # plug Tesla.Middleware.DecodeRels
  plug FleetBot.Fleetyards.DecodeRels

  def new(token) do
    middleware = [{Tesla.Middleware.BearerAuth, :call, [[token: token]]} | __middleware__()]
    %Tesla.Client{pre: middleware, post: []}
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

  #  use HTTPoison.Base
  #
  #  def api_url(), do: Application.fetch_env!(:fleet_bot, FleetBot.Fleetyards)[:api_url]
  #
  #  @overwrite_headers ~w(content-type user-agent)
  #
  #  @impl HTTPoison.Base
  #  def process_request_url(path) do
  #    api_url() <> path
  #  end
  #
  #  @impl HTTPoison.Base
  #  def process_response_body(body) do
  #    case Jason.decode(body) do
  #      {:ok, v} -> v
  #      _ -> body
  #    end
  #  end
  #
  #  @impl HTTPoison.Base
  #  def process_request_headers(headers) do
  #    [
  #      {"Content-Type", "application/json"},
  #      {"User-Agent",
  #       "FleetBot/#{get_version()} (#{:erlang.system_info(:system_architecture)}) OTP/#{:erlang.system_info(:otp_release)} (#{String.trim(:binary.list_to_bin(:erlang.system_info(:system_version)))})"}
  #      | Enum.filter(headers, fn {header, _value} ->
  #          header = String.downcase(header)
  #          Enum.member?([@overwrite_headers], header)
  #        end)
  #    ]
  #  end
  #
  #  @impl HTTPoison.Base
  #  def process_request_body(%{} = body) do
  #    Jason.encode!(body)
  #  end
  #
  #  @impl HTTPoison.Base
  #  def process_request_body(body), do: body
  #
end
