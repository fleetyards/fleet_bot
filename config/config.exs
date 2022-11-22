import Config

config :fleet_bot,
  namespace: FleetBot,
  ecto_repos: [FleetBot.Repo]

config :fleet_bot, FleetBot.Repo, pool_size: 10

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
