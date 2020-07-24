defmodule Oliya.Backend.Tectonicdb.RetrieverTest do
  use ExUnit.Case, async: false
  alias Oliya.Backend.Retriever.{Params, Reseponse}

  setup do
    backend = Oliya.Backend.Tectonicdb
    pid = start_supervised!(backend)

    [
      pid: pid,
      backend: backend,
      venue: :venue_a,
      symbol: :btc_usd
    ]
  end

  setup context do
    conn = Process.whereis(Oliya.Backend.Tectonicdb.reader_name())
    db = Oliya.Backend.Tectonicdb.Recorder.db_name(context.venue, context.symbol)

    case ExTectonicdb.Commands.exists?(conn, "default") do
      {:error, :db_not_found} -> ExTectonicdb.Commands.create(conn, db)
      _ -> nil
    end

    {:ok, _} = ExTectonicdb.Commands.use_db(conn, db)
    :ok = ExTectonicdb.Commands.clear(conn)
    context
  end

  test "nada", %{backend: backend, venue: venue, symbol: symbol} do
    backend.insert(
      trade_event(%{
        price: 1001.0,
        venue_id: venue,
        symbol: symbol,
        timestamp: ~U(2000-01-01 22:59:59.000000Z),
        size: 2
      })
    )

    backend.insert(trade_event(%{price: 1000, venue_id: venue, symbol: symbol, size: 3}))
    backend.insert(trade_event(%{price: 1001.0, venue_id: venue, symbol: symbol, size: 4}))

    params = %Params{
      from: ~U(1999-01-01 23:00:00.000000Z),
      to: ~U(2000-01-01 23:00:02.000000Z),
      symbol: symbol,
      granularity: "1m",
      venue: venue
    }

    assert {:ok,
            %Reseponse{
              columns: columns,
              data: data,
              from: ~U[1999-01-01 23:00:00.000000Z],
              granularity: "1m",
              symbol: :btc_usd,
              to: ~U[2000-01-01 23:00:02.000000Z],
              venue: :venue_a
            }} = Module.concat(backend, "Retriever").fetch(params)

    assert columns == ~w(date open high low close volume)a

    assert data == [
             ["2000-01-01 22:59:00.000Z", 1001.0, 1001.0, 1001.0, 1001.0, 1.0],
             ["2000-01-01 23:00:00.000Z", 1.0e3, 1001.0, 1.0e3, 1.0e3, 2.0]
           ]
  end

  defp trade_event(override) do
    %{
      price: 1000,
      qty: 1.0,
      venue_id: :custom_venue,
      symbol: :btc_usd,
      timestamp: ~U(2000-01-01 23:00:01.000000Z),
      taker_side: :buy,
      venue_trade_id: 1
    }
    |> Map.merge(override)
  end
end
