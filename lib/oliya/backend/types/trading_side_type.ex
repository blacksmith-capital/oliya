defmodule Oliya.Backend.Types.TradingSideType do
  @moduledoc """
  Cast trading side to boolean
  """
  use Ecto.Type

  @doc """
  Return ecto type as string.

  ## Examples

        iex> TradingSideType.type()
        :boolean
  """
  def type, do: :boolean

  @doc """
  Casts the value to an atom.

  ## Examples

      iex> TradingSideType.cast(:buy)
      {:ok, :buy}
  """
  def cast(value), do: {:ok, value}

  @doc """
  Loads the atom value from the given string.

  ## Examples

      iex> TradingSideType.load(true)
      {:ok, :buy}

      iex> TradingSideType.load(false)
      {:ok, :sell}
  """
  def load(true), do: {:ok, :buy}
  def load(false), do: {:ok, :sell}

  @doc """
  Dumps the atom value as a string.

  ## Examples

      iex> TradingSideType.dump(:buy)
      {:ok, true}

      iex> TradingSideType.dump(:sell)
      {:ok, false}

      iex> TradingSideType.dump(123)
      :error
  """
  def dump(:buy), do: {:ok, true}
  def dump(:sell), do: {:ok, false}
  def dump(_), do: :error
end
