defmodule Oliya.History.Backend.Tectonicdb do
  alias Oliya.History.Backend
  @behaviour Backend

  @impl Backend
  def insert(event), do: event |> to_model |> do_insert(nil)

  defp to_model(%{
         price: price,
         qty: volume,
         venue_id: venue_id,
         symbol: symbol,
         timestamp: timestamp,
         side: side,
         venue_trade_id: _venue_trade_id
       }) do
    model = %ExTectonicdb.Dtf{
      timestamp: timestamp,
      seq: 0,
      is_trade: true,
      is_bid: to_side(side),
      price: to_float(price),
      size: to_float(volume)
    }

    db = db_name(venue_id, symbol)

    {model, db}
  end

  defp do_insert({dtf, db}, conn), do: ExTectonicdb.Commands.insert_into(conn, dtf, db)
  defp db_name(venue, symbol), do: Enum.join([venue, symbol], "_")

  defp to_side(:buy), do: true
  defp to_side(:sell), do: false

  defp to_float(%Decimal{} = v), do: v |> Decimal.to_float()
  defp to_float(v), do: Ecto.Type.cast(:float, v) |> elem(1)
end
