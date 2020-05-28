defmodule Oliya.Retriever.Postgres.IntervalRounder do
  def round(granularity, from, to) do
    from_unix = DateTime.to_unix(from)
    to_unix = DateTime.to_unix(to)

    secs = granularity_to_secs(granularity)

    {:ok, from} = (from_unix - rem(from_unix, secs)) |> DateTime.from_unix()
    {:ok, to} = (to_unix - rem(to_unix, secs) + secs) |> DateTime.from_unix()

    {from, to}
  end

  defp granularity_to_secs(%{days: days, secs: secs}),
    do: (days * 24 * :math.pow(60, 2) + secs) |> Kernel.trunc()
end
