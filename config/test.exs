import Config

config :nostrum,
  dev: true

config :fleet_bot, FleetBot.Repo,
  username: "fleet_bot_test",
  password: "fleet_bot_test",
  database: "fleet_bot_test",
  hostname: "localhost",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

config :tesla, adapter: Tesla.Mock

config :fleet_bot, FleetBot.Fleetyards, api_url: "https://api.example.org/"
