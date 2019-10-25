defmodule OliyaWeb.Api.V1.OhlcControllerTest do
  use Oliya.Support.WithSharedRepo
  use OliyaWeb.ConnCase
  import Routes

  test "#index fetches" do
    conn = build_conn()
    time_str = '2019-01-01 00:00:00'

    {:ok, %Postgrex.Result{num_rows: 1}} =
      ~s"""
      insert into trades (venue, symbol, timestamp, price, volume, side, inserted_at, updated_at)
      values ('bitmex', 'xbtusd', '#{time_str}', 8000.5,100,true,now(), now());
      """
      |> Oliya.Repo.query()

    venue = "bitmex"
    symbol = "XBTUSD"

    from =
      DateTime.from_iso8601("#{time_str}Z")
      |> elem(1)
      |> DateTime.to_unix(:millisecond)
      |> Integer.to_string()

    to =
      DateTime.from_iso8601("#{time_str}Z")
      |> elem(1)
      |> DateTime.to_unix(:millisecond)
      |> Kernel.+(1)
      |> Integer.to_string()

    granularity = "1m"

    params = %{
      "venue" => venue,
      "symbol" => symbol,
      "from" => from,
      "to" => to,
      "granularity" => granularity
    }

    conn = get(conn, ohlc_path(conn, :index, params))

    assert %{
             "venue" => ^venue,
             "symbol" => ^symbol,
             "columns" => ~w(date open high low close volume),
             "from" => "2019-01-01T00:00:00Z",
             "to" => "2019-01-01T00:01:00Z",
             "granularity" => ^granularity,
             "data" => [
               ["2019-01-01T00:00:00.000000", _, _, _, _, _]
             ]
           } = json_response(conn, 200)
  end
end
