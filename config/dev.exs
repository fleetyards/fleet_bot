import Config

config :nostrum,
  token: System.fetch_env("FLEET_BOT_TOKEN")

# config :fleet_bot, FleetBot.Fleetyards, api_url: "https://stage.fleetyards.net/api"

config :fleet_bot, FleetBot.Repo,
  username: "fleet_bot_dev",
  password: "fleet_bot_dev",
  database: "fleet_bot_dev",
  hostname: "localhost",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :logger, :console, metadata: [:shard, :guild, :channel]

if System.get_env("FLEET_BOT_APPSIGNAL") != nil do
  config :appsignal, :config,
    active: true,
    env: :dev,
    push_api_key: System.fetch_env!("FLEET_BOT_APPSIGNAL")
end

if File.exists?("./config/dev.secrets.exs") do
  import_config "dev.secrets.exs"
end
