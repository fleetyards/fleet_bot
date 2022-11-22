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
        fleet_bot: []
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

      # Gettext
      {:gettext, "~> 0.20"},

      # Dev
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      fmt: ["format"]
    ]
  end
end
