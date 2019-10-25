defmodule Oliya.Repo do
  use Ecto.Repo,
    otp_app: :oliya,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    case Mix.env() do
      :prod -> {:ok, Keyword.put(config, :url, System.get_env("DATABASE_URL"))}
      _ -> {:ok, build_config(config)}
    end
  end

  defp build_config([{_, _} = i | tail]) do
    item = parse_config_item(i)
    [item | build_config(tail)]
  end

  defp build_config([]), do: []

  defp parse_config_item({k, {:system, env_name, default}}),
    do: {k, System.get_env(env_name, default)}

  defp parse_config_item({k, {:system, env_name}}),
    do: parse_config_item({k, {:system, env_name, nil}})

  defp parse_config_item({k, v}), do: {k, v}
end
