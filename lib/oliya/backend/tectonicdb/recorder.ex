defmodule Oliya.Backend.Tectonicdb.Recorder do
  alias Oliya.Backend
  @behaviour Backend

  @impl Backend
  def insert(event) do
    conn = Process.whereis(Oliya.Backend.Tectonicdb)
    event |> to_model |> do_insert(conn)
  end

  # trade
  defp to_model(%{
         price: price,
         qty: volume,
         venue_id: venue_id,
         symbol: symbol,
         timestamp: timestamp,
         taker_side: side,
         venue_trade_id: _venue_trade_id
       })
       when not is_nil(timestamp) do
    model = %ExTectonicdb.Dtf{
      timestamp: timestamp |> DateTime.to_unix(:microsecond),
      seq: 0,
      is_trade: true,
      is_bid: to_side(side),
      price: to_float(price),
      size: to_float(volume)
    }

    db = db_name(venue_id, symbol)

    {model, db}
  end

  # order
  defp to_model(%{
         price: price,
         qty: volume,
         venue_id: venue_id,
         symbol: symbol,
         timestamp: timestamp,
         side: side,
         seq: seq
       })
       when not is_nil(timestamp) do
    model = %ExTectonicdb.Dtf{
      timestamp: timestamp,
      seq: seq,
      is_trade: false,
      is_bid: to_side(side),
      price: to_float(price),
      size: to_float(volume)
    }

    db = db_name(venue_id, symbol)

    {model, db}
  end

  defp do_insert({dtf, db}, conn) do
    case ExTectonicdb.Commands.insert_into(conn, dtf, db) do
      {:ok, model, _} ->
        {:ok, model}

      {:error, :db_not_found} ->
        {:ok, _} = create(conn, db)
        {:ok, model, _} = ExTectonicdb.Commands.insert_into(conn, dtf, db)
        {:ok, model}
    end
  end

  def db_name(venue, symbol), do: Enum.join([venue, symbol], "_")

  defp to_side(s) when s in ~w[buy bid]a, do: true
  defp to_side(s) when s in ~w[ask sell]a, do: false

  defp to_float(%Decimal{} = v), do: v |> Decimal.to_float()
  defp to_float(v), do: Ecto.Type.cast(:float, v) |> elem(1)

  defp create(conn, db), do: ExTectonicdb.Commands.create(conn, db)
end
