defmodule Oliya.MixProject do
  use Mix.Project

  def project do
    [
      aliases: aliases(),
      app: :oliya,
      version: "0.1.0",
      elixir: "~> 1.8",
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      mod: {Oliya.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.0"},
      {:ex_tectonicdb, "~> 0.1.0"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:logger_file_backend, "~> 0.0.10"},
      {:mapail, "~> 1.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix_live_dashboard, "~> 0.7"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix, "~> 1.7"},
      {:plug_cowboy, "~> 2.0"},
      {:postgrex, ">= 0.0.0"},
      {:tai, github: "yurikoval/tai", branch: "main", sparse: "apps/tai"}
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "_build/#{Mix.env()}/dialyzer.plt"},
      flags: [
        :unmatched_returns,
        :error_handling,
        :underspecs,
        :no_opaque
      ],
      plt_add_deps: :transitive,
      ignore_warnings: "dialyzer.ignore-warnings"
    ]
  end

  defp aliases do
    [
      test: "test --no-start",
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      setup: ["deps.get", "ecto.setup", "cmd --cd assets npm install"],
      "assets.deploy": ["cmd --cd assets node build.js --deploy", "phx.digest"]
    ]
  end

  defp package do
    %{
      maintainers: ["Yuri Koval'ov"]
    }
  end
end
