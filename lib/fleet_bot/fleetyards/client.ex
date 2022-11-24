defmodule FleetBot.Fleetyards.Client do
  use HTTPoison.Base

  def api_url(), do: Application.fetch_env!(:fleet_bot, FleetBot.Fleetyards)[:api_url]

  @overwrite_headers ~w(content-type user-agent)

  @impl HTTPoison.Base
  def process_request_url(path) do
    api_url() <> path
  end

  @impl HTTPoison.Base
  def process_response_body(body) do
    case Jason.decode(body) do
      {:ok, v} -> v
      _ -> body
    end
  end

  @impl HTTPoison.Base
  def process_request_headers(headers) do
    [
      {"Content-Type", "application/json"},
      {"User-Agent",
       "FleetBot/#{get_version()} (#{:erlang.system_info(:system_architecture)}) OTP/#{:erlang.system_info(:otp_release)} (#{String.trim(:binary.list_to_bin(:erlang.system_info(:system_version)))})"}
      | Enum.filter(headers, fn {header, _value} ->
          header = String.downcase(header)
          Enum.member?([@overwrite_headers], header)
        end)
    ]
  end

  @impl HTTPoison.Base
  def process_request_body(%{} = body) do
    Jason.encode!(body)
  end

  @impl HTTPoison.Base
  def process_request_body(body), do: body

  def get_version() do
    Application.spec(:fleet_bot)[:vsn]
  end
end
