defmodule Oliya.Backend.Types.AtomType do
  @moduledoc """
  Cast atom type to string when dumping to database; cast to atom when reading from database.
  """
  use Ecto.Type

  @doc """
  Return ecto type as string.

  ## Examples

        iex> AtomType.type()
        :string
  """
  def type, do: :string

  @doc """
  Casts the value to an atom.

  ## Examples

      iex> AtomType.cast(:test)
      {:ok, :test}
  """
  def cast(value), do: {:ok, value}

  @doc """
  Loads the atom value from the given string.

  ## Examples

      iex> AtomType.load("test")
      {:ok, :test}
  """
  def load(value), do: {:ok, String.to_atom(value)}

  @doc """
  Dumps the atom value as a string.

  ## Examples

      iex> AtomType.dump(:test)
      {:ok, "test"}

      iex> AtomType.dump("test")
      {:ok, "test"}

      iex> AtomType.dump(123)
      :error
  """
  def dump(value) when is_atom(value), do: {:ok, Atom.to_string(value)}
  def dump(value) when is_binary(value), do: {:ok, value}
  def dump(_), do: :error
end
