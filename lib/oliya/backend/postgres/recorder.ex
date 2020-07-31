defmodule Oliya.Backend.Postgres.Recorder do
  alias Oliya.Backend
  @behaviour Backend

  defmodule Trade do
    @moduledoc false
    use Ecto.Schema

    schema "trades" do
      field(:venue, :string)
      field(:symbol, :string)
      field(:price, :float)
      field(:volume, :float)
      field(:timestamp, :utc_datetime_usec)
      field(:side, :boolean)
      field(:venue_trade_id, :string)

      timestamps()
    end
  end

  defp to_model(%{
         price: price,
         qty: volume,
         taker_side: side,
         symbol: instrument,
         timestamp: timestamp,
         venue_id: venue_id,
         venue_trade_id: venue_trade_id
       }) do
    struct!(Trade, %{
      venue: venue_id |> Atom.to_string(),
      symbol: instrument |> Atom.to_string(),
      price: price |> to_price(),
      volume: volume |> to_volume(),
      timestamp: timestamp |> to_timestamp(),
      side: side |> to_side(),
      venue_trade_id: venue_trade_id |> to_venue_trade_id
    })
  end

  # order
  defp to_model(%{
         price: _price,
         qty: _volume,
         seq: _seq,
         venue_id: _venue_id,
         symbol: _instrument,
         timestamp: _timestamp,
         side: _side
       }) do
    # noop for now - not recordering orders in pg
    :skip
  end

  defp to_price(%Decimal{} = v), do: v |> Decimal.to_float()
  defp to_price(v), do: Ecto.Type.cast(:float, v) |> elem(1)
  defp to_volume(%Decimal{} = v), do: v |> Decimal.to_float()
  defp to_volume(v), do: Ecto.Type.cast(:float, v) |> elem(1)
  defp to_timestamp(v), do: v |> DateTime.from_unix!(:microsecond)
  defp to_side(:buy), do: true
  defp to_side(:sell), do: false
  defp to_venue_trade_id(s) when is_integer(s), do: Integer.to_string(s)
  defp to_venue_trade_id(s), do: s

  @impl Backend
  def insert(event) do
    case to_model(event) do
      %Trade{} = trade -> pg_insert(trade)
      :skip -> {:error, :not_supported}
    end
  end

  defp pg_insert(e), do: Oliya.Backend.Postgres.to_name().insert(e)
end
