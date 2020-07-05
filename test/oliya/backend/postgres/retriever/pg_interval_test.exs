defmodule Oliya.Backend.Postgres.Retriever.PgIntervalTest do
  use ExUnit.Case, async: true
  alias Oliya.Backend.Postgres.Retriever.PgInterval

  test "it converts" do
    assert PgInterval.from_string("1m") == %Postgrex.Interval{secs: 60}
    assert PgInterval.from_string("15m") == %Postgrex.Interval{secs: 60 * 15}
    assert PgInterval.from_string("5m") == %Postgrex.Interval{secs: 300}
    assert PgInterval.from_string("1h") == %Postgrex.Interval{secs: 3600}
    assert PgInterval.from_string("1d") == %Postgrex.Interval{days: 1}
    assert PgInterval.from_string("5d") == %Postgrex.Interval{days: 5}
    assert PgInterval.from_string("15d") == %Postgrex.Interval{days: 15}
  end
end
