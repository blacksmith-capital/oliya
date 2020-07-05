defmodule Oliya.Backend.Supervisor do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  def init(_) do
    children = [
      {Oliya.Backend.Recorder, [backend: backend()]},
      backend()
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp backend do
    Application.get_env(:oliya, :backend, Oliya.Backend.Postgres)
  end
end
