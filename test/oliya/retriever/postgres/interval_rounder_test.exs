defmodule Oliya.Retriever.Postgres.IntervalRounderTest do
  use ExUnit.Case, async: true
  alias Oliya.Retriever.Postgres.{IntervalRounder, PgInterval}

  test "it rountes to nearest 1m" do
    assert {~U[2000-01-01 01:00:00Z], ~U[2000-01-01 01:01:00Z]} =
             IntervalRounder.round(
               "1m" |> PgInterval.from_string(),
               ~U[2000-01-01 01:00:02.000000Z],
               ~U[2000-01-01 01:00:02.000000Z]
             )
  end

  test "it rountes to nearest 5m" do
    assert {~U[2000-01-01 01:00:00Z], ~U[2000-01-01 02:05:00Z]} =
             IntervalRounder.round(
               "5m" |> PgInterval.from_string(),
               ~U[2000-01-01 01:00:02.000000Z],
               ~U[2000-01-01 02:00:02.000000Z]
             )
  end

  test "it rountes to nearest 1h" do
    assert {~U[2000-01-01 01:00:00Z], ~U[2000-01-01 03:00:00Z]} =
             IntervalRounder.round(
               "1h" |> PgInterval.from_string(),
               ~U[2000-01-01 01:00:02.000000Z],
               ~U[2000-01-01 02:00:02.000000Z]
             )

    assert {~U[2000-01-01 01:00:00Z], ~U[2000-01-01 02:00:00Z]} =
             IntervalRounder.round(
               "1h" |> PgInterval.from_string(),
               ~U[2000-01-01 01:00:02.000000Z],
               ~U[2000-01-01 01:50:02.000000Z]
             )
  end

  test "it rountes to nearest 1d" do
    assert {~U[2000-01-01 00:00:00Z], ~U[2000-01-02 00:00:00Z]} =
             IntervalRounder.round(
               "1d" |> PgInterval.from_string(),
               ~U[2000-01-01 01:00:02.000000Z],
               ~U[2000-01-01 02:00:02.000000Z]
             )
  end
end
