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

    Postgres.Recorder.insert(event)

    trade =
      from(trades in Postgres.Recorder.Trade) |> Postgres.Repo.all() |> List.first()

    assert trade.venue == :bitfinex
    assert trade.symbol == :BTCUSD
    assert trade.price == Decimal.new("1000.0")
    assert trade.volume == Decimal.new("42")
    assert trade.timestamp == DateTime.from_unix!(1_689_269_692_000_000, :microsecond)
    assert trade.side == :buy
  end
end
