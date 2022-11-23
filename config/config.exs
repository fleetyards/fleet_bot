import Config

config :fleet_bot,
  namespace: FleetBot,
  ecto_repos: [FleetBot.Repo]

config :fleet_bot, FleetBot.Repo, pool_size: 10

config :fleet_bot, FleetBot.Gettext, locales: ~w(de), default_locale: :de

config :fleet_bot, FleetBot.Discord,
  discord_allowed_langs:
    ~w(ar da vi hu uk lt ja hi tr cs th zh-TW el pl zh-CN ko de en-GB fi id ru sv-SE bg es-ES it pt-BR nl ro fr no hr he en-US)

config :fleet_bot, FleetBot.Fleetyards,
  api_url: "https://api.fleetyards.net",
  client: FleetBot.Fleetyards.Client

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
