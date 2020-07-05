defmodule Oliya.Backend.Tectonicdb do
  use Supervisor

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_args) do
    children = [worker(ExTectonicdb, [[name: __MODULE__]])]
    Supervisor.init(children, strategy: :one_for_one)
  end

  defdelegate insert(event), to: __MODULE__.Recorder
end
