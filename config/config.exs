import Config

config :fleet_bot,
  namespace: FleetBot,
  ecto_repos: [FleetBot.Repo]

config :fleet_bot, FleetBot.Repo, pool_size: 10

config :fleet_bot, FleetBot.Gettext, locales: ~w(de en-US), default_locale: :de

config :fleet_bot, FleetBot.Discord,
  discord_allowed_langs:
    ~w(ar da vi hu uk lt ja hi tr cs th zh-TW el pl zh-CN ko de en-GB fi id ru sv-SE bg es-ES it pt-BR nl ro fr no hr he en-US)

config :fleet_bot, FleetBot.Fleetyards,
  api_url: "https://api.fleetyards.net",
  client: FleetBot.Fleetyards.Client

config :fleet_bot, FleetBot.Fleetyards.Cache,
  # When using :shards as backend
  backend: :shards,
  # GC interval for pushing new generation: 12 hrs
  gc_interval: :timer.hours(3),
  # Max 500 thousand entries in cache
  max_size: 500_000,
  # Max 500 MB of memory
  allocated_memory: 500_000_000,
  # GC min timeout: 10 sec
  gc_cleanup_min_timeout: :timer.seconds(10),
  # GC max timeout: 10 min
  gc_cleanup_max_timeout: :timer.minutes(10)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
if Kernel.macro_exported?(Config, :config_env, 0) do
  import_config "#{Config.config_env()}.exs"
else
  import_config "#{Mix.env()}.exs"
end
