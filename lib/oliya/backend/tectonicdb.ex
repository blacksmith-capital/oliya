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
    children = [
      worker(ExTectonicdb, [[name: reader_name()]], id: reader_name()),
      worker(ExTectonicdb, [[name: writer_name()]], id: writer_name())
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def writer_name, do: :tectonicdb_writer
  def reader_name, do: :tectonicdb_reader

  defdelegate insert(event), to: __MODULE__.Recorder
end
