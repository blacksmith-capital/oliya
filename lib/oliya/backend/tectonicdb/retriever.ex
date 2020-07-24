defmodule Oliya.Backend.Tectonicdb.Retriever do
  alias Oliya.Backend.Retriever
  alias Oliya.Backend.Tectonicdb.OhlcCalculator
  import Oliya.Backend.Tectonicdb.Recorder, only: [db_name: 2]
  @behaviour Retriever

  @columns ~w(date open high low close volume)a

  @impl Retriever
  def fetch(%Retriever.Params{} = params) do
    from = DateTime.to_unix(params.from, :millisecond)
    to = DateTime.to_unix(params.to, :millisecond)
    db = db_name(params.venue, params.symbol)

    {:ok, _} = ExTectonicdb.Commands.use_db(conn(), db)

    {:ok, rows} = ExTectonicdb.Commands.get_all(conn(), from: from, to: to)

    response_params =
      params
      |> Map.from_struct()
      |> Map.put(:columns, @columns)
      |> Map.put(:data, OhlcCalculator.calculate(rows, params.granularity))

    response = struct(Retriever.Reseponse, response_params)

    {:ok, response}
  end

  defp conn(), do: Process.whereis(Oliya.Backend.Tectonicdb.reader_name())
end
