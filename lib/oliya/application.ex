defmodule Oliya.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Oliya.Backend.Supervisor, []},
      {Phoenix.PubSub, [name: Oliya.PubSub, adapter: Phoenix.PubSub.PG2]},
      OliyaWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Oliya.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    OliyaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
