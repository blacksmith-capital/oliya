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
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:ex_tectonicdb, "~> 0.1.0"},
      {:phoenix, "~> 1.4.7"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:mapail, "~> 1.0"},
      {:logger_file_backend, "~> 0.0.10"},
      {:tai, "~> 0.0.44"}
    ]
  end

  defp aliases, do: [test: "test --no-start"]

  defp package do
    %{
      maintainers: ["Yuri Koval'ov"]
    }
  end
end
