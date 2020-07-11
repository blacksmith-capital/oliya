defmodule Oliya.Backend.Tectonicdb.OhlcCalculator do
  def calculate(rows, granularity) do
    roundto = string_to_ms(granularity)

    rows
    |> Enum.group_by(fn %{timestamp: ts} ->
      rounded = round(ts)
      rounded - rem(rounded, roundto)
    end)
    |> Enum.map(fn {ts, r} ->
      {low_dtf, high_dtf} = Enum.min_max_by(r, & &1.price)

      [
        ts |> DateTime.from_unix!(:millisecond) |> DateTime.to_string(),
        r |> Enum.min_by(& &1.timestamp) |> Map.get(:price),
        Map.get(high_dtf, :price),
        Map.get(low_dtf, :price),
        r |> Enum.max_by(& &1.timestamp) |> Map.get(:price),
        r |> Enum.map(& &1.size) |> Enum.sum()
      ]
    end)
  end

  defp string_to_ms("1m"), do: 1000 * 60
  defp string_to_ms("5m"), do: 1000 * 60 * 5
  defp string_to_ms("15m"), do: 1000 * 60 * 15
  defp string_to_ms("1h"), do: 1000 * 60 * 60
  defp string_to_ms("1d"), do: 1000 * 60 * 60 * 24
  defp string_to_ms("5d"), do: 1000 * 60 * 60 * 24 * 5
  defp string_to_ms("15d"), do: 1000 * 60 * 60 * 24 * 15
end
