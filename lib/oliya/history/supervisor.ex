defmodule Oliya.History.Supervisor do
  use Supervisor
  alias Oliya.History.Backend.{Postgres, Tectonicdb}

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(arg) do
    history_worker = {Oliya.History.Worker, [backend: backend_config()]}
    backend_worker = backend_worker(backend_config(), arg)

    [history_worker, backend_worker]
    |> Supervisor.init(strategy: :one_for_one)
  end

  defp backend_worker(Postgres, args) do
    worker(Oliya.Repo, [args])
  end

  defp backend_worker(Tectonicdb, _args) do
    worker(ExTectonicdb, [[name: Tectonicdb]])
  end

  defp backend_config, do: Application.get_env(:oliya, :backend, Tectonicdb)
end