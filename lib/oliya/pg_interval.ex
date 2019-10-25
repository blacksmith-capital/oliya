defmodule Oliya.PgInterval do
  @moduledoc """
  Handles string to postgres interval conversion
  """
  @supported_units ~w(m h d)

  def from_string(<<digit::bytes-size(1)>> <> unit) when unit in @supported_units,
    do: convert(unit, digit)

  def from_string(<<digit::bytes-size(2)>> <> unit) when unit in @supported_units,
    do: convert(unit, digit)

  defp convert(unit, digit) do
    length = String.to_integer(digit)

    case unit do
      "m" -> %Postgrex.Interval{secs: length * 60}
      "h" -> %Postgrex.Interval{secs: length * 60 * 60}
      "d" -> %Postgrex.Interval{days: length}
    end
  end
end
