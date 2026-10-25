defmodule Oliya.Backend.Postgres.RecorderTest do
  use ExUnit.Case, async: false
  use Oliya.Support.WithSharedRepo

  alias Oliya.Backend.Postgres
  import Ecto.Query

  test "it inserts into the db" do
    event = %{
      price: Decimal.new("1000.0"),
      taker_side: :buy,
      symbol: :BTCUSD,
      timestamp: 1_689_269_692_000_000,
      venue_id: :bitfinex,
      qty: Decimal.new("42"),
      venue_trade_id: 1
    }

    assert_trade_inserted(event)
  end

  test "it inserts decimal strings emitted by venue adapters" do
    event = %{
      price: "80615.66000000",
      taker_side: :sell,
      symbol: :btc_usdt,
      timestamp: 1_689_269_692_000_000,
      venue_id: :binance,
      qty: "0.00132000",
      venue_trade_id: 6_789_610_359
    }

    assert_trade_inserted(event)
  end

  defp assert_trade_inserted(event) do
    Postgres.Recorder.insert(event)

    trade =
      from(trades in Postgres.Recorder.Trade) |> Postgres.Repo.all() |> List.first()

    assert trade.venue == event.venue_id
    assert trade.symbol == event.symbol
    assert trade.price == to_decimal(event.price)
    assert trade.volume == to_decimal(event.qty)
    assert trade.timestamp == DateTime.from_unix!(event.timestamp, :microsecond)
    assert trade.side == event.taker_side
  end

  defp to_decimal(%Decimal{} = value), do: value
  defp to_decimal(value), do: Decimal.new(value)
end
