import Config

config :nostrum,
  token: System.get_env("FLEET_BOT_TOKEN", "")

config :fleet_bot, FleetBot.Repo,
  username: "fleet_bot_test",
  password: "fleet_bot_test",
  database: "fleet_bot_test",
  hostname: "localhost",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true
