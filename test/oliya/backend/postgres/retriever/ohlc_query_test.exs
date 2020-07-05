defmodule Oliya.Backend.Postgres.Retriever.OhlcQueryTest do
  use Oliya.Support.WithSharedRepo
  alias Oliya.Backend.Postgres.Retriever.OhlcQuery

  test "it fetches 1m summary using range" do
    instrument = "xbtusd"
    from_timestamp = ~U(2000-01-01 23:00:01.000000Z)
    to_timestamp = ~U(2000-01-01 23:00:02.000000Z)
    add_trade(price: 1000.0, timestamp: from_timestamp)

    assert {:ok, %{data: data}, {~U(2000-01-01 23:00:00Z), ~U(2000-01-01 23:01:00Z)}} =
             OhlcQuery.get(%{
               from: from_timestamp,
               to: to_timestamp,
               venue: "bitmex",
               granularity: "1m",
               symbol: instrument
             })

    assert [[~N[2000-01-01 23:00:00.000000], 1.0e3, 1.0e3, 1.0e3, 1.0e3, 100.0]] = data
  end

  def add_trade(keywordlist) do
    params = keywordlist |> Map.new()

    map =
      %{
        venue: "bitmex",
        symbol: "xbtusd",
        price: 100,
        side: true,
        timestamp: ~U(2000-01-01 23:00:01.000000Z),
        volume: 100
      }
      |> Map.merge(params)

    keys = (map |> Map.keys() |> Enum.join(", ")) <> ", inserted_at, updated_at"
    values = map |> Map.values() |> Enum.map(&"'#{&1}'") |> Enum.join(", ")

    {:ok, %Postgrex.Result{num_rows: 1}} =
      ~s"""
      insert into trades (#{keys})
      values (#{values},now(), now());
      """
      |> Repo.query()
  end
end
