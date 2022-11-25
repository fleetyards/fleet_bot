defmodule FleetBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :fleet_bot,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      releases: [
        fleet_bot: [
          config_providers: [{FleetBot.Config.ReleaseRuntimeProvider, []}]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {FleetBot.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Discord
      {:nostrum, "~> 0.6"},
      {:jason, "~> 1.2"},
      {:httpoison, "~> 1.8"},

      # Database
      {:ecto, "~> 3.8"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},

      # Cache
      {:nebulex, "~> 2.4"},
      {:shards, "~> 1.0"},
      {:decorator, "~> 1.4"},
      {:telemetry, "~> 1.0"},

      # Status
      {:appsignal, "~> 2.0"},
      {:telemetry_metrics_appsignal, "~> 1.0"},

      # Gettext
      {:gettext, "~> 0.20"},

      # Dev
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:mox, "~> 0.5.2", only: :test}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      # , "run priv/repo/seeds.exs"
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.rollback --all", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test --no-start"],
      fmt: ["format"]
    ]
  end
end
