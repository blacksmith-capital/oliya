defmodule Oliya.Backend.Postgres.Retriever.OhlcQuery do
  alias Oliya.Backend.Postgres.Repo
  alias Oliya.Backend.Postgres.Retriever.{IntervalRounder, PgInterval}

  defmodule Response do
    defstruct ~w(columns data meta)a
  end

  @moduledoc """
  Query module to fetch ohlcv ticks from database
  """

  @doc """
   sql string used to query

   $1 - venue
   $2 - symbol
   $3 - from
   $4 - to
   $5 - granularity
   VENUE_TABLE - venue_id
  """

  @sql ~S"""
  with intervals as (
    select start, start + $5::interval as end
    from generate_series($3::timestamp, $4::timestamp, $5::interval) as start
  )
  select distinct
    intervals.start as date,
    first_value(price) over w as open,
    max(price) over w as high,
    min(price) over w as low,
    last_value(price) over w as close,
    sum(volume) over w as volume
  from
    intervals
    join trades mb on
      mb.venue = $1
      AND mb.symbol = $2
      AND mb.timestamp >= intervals.start
      AND mb.timestamp < intervals.end
  window w as (partition by intervals.start order by mb.timestamp asc rows between unbounded preceding and unbounded following)
  order by intervals.start
  """

  def get(%{
        symbol: symbol,
        venue: venue,
        from: from,
        to: to,
        granularity: granularity_raw
      }) do
    granularity = PgInterval.from_string(granularity_raw)
    {from, to} = IntervalRounder.round(granularity, from, to)

    {:ok, %Postgrex.Result{columns: columns, num_rows: count, rows: rows}} =
      Repo.query(@sql, [venue, symbol, from, to, granularity])

    response = %Response{
      columns: columns,
      data: rows,
      meta: %{total_count: count}
    }

    {:ok, response, {from, to}}
  end
end
