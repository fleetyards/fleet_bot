import Config

config :appsignal, :config,
  # Maybe deactivate, and only activate via release config?
  active: true,
  env: :prod
