defmodule Oliya.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Oliya.History.Backend, []},
      Oliya.History.Worker,
      # Start the endpoint when the application starts
      OliyaWeb.Endpoint,
      # Starts a worker by calling: Oliya.Worker.start_link(arg)
      # {Oliya.Worker, arg},
      Oliya.HistoryPurger
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Oliya.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    OliyaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
