defmodule Oliya.History do
  @moduledoc """
  Subscrive to trade events and collect history into persisted store
  """
  defmodule Trade do
    @moduledoc false
    use Ecto.Schema

    schema "trades" do
      field(:venue, :string)
      field(:symbol, :string)
      field(:price, :float)
      field(:volume, :float)
      field(:timestamp, :utc_datetime_usec)
      field(:side, :boolean)
      field(:venue_trade_id, :string)

      timestamps()
    end

    def delete_before(%DateTime{} = ts) do
      ~S"""
      DELETE
      FROM trades
      WHERE timestamp <= $1;
      """
      |> Oliya.Repo.query([ts])
    end
  end

  defmodule Worker do
    use GenServer
    require Logger

    @type event :: map
    @type level :: Tai.Events.level()
    @type state :: :ok

    @subscribe_to [
      Tai.Events.Trade
    ]

    def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

    @spec init(state) :: {:ok, state}
    def init(state) do
      Enum.each(@subscribe_to, &TaiEvents.subscribe/1)
      {:ok, state}
    end

    @spec handle_info({Tai.Event, event, level}, state) :: {:noreply, state}
    def handle_info({Tai.Event, event, _level}, state) do
      event |> to_model |> insert
      {:noreply, state}
    end

    defp to_model(%{
           price: price,
           qty: volume,
           venue_id: venue_id,
           symbol: instrument,
           timestamp: timestamp,
           side: side,
           venue_trade_id: venue_trade_id
         }) do
      struct!(Oliya.History.Trade, %{
        venue: venue_id |> Atom.to_string(),
        symbol: instrument |> Atom.to_string(),
        price: price |> to_price(),
        volume: volume |> to_volume(),
        timestamp: timestamp |> to_timestamp(),
        side: side |> to_side(),
        venue_trade_id: venue_trade_id |> to_venue_trade_id
      })
    end

    defp to_price(%Decimal{} = v), do: v |> Decimal.to_float()
    defp to_price(v), do: Ecto.Type.cast(:float, v) |> elem(1)
    defp to_volume(%Decimal{} = v), do: v |> Decimal.to_float()
    defp to_volume(v), do: Ecto.Type.cast(:float, v) |> elem(1)
    defp to_timestamp(v), do: Ecto.Type.cast(:utc_datetime_usec, v) |> elem(1)
    defp to_side(:buy), do: true
    defp to_side(:sell), do: false
    defp to_venue_trade_id(s) when is_integer(s), do: Integer.to_string(s)
    defp to_venue_trade_id(s), do: s

    defdelegate insert(r), to: Oliya.Repo
  end
end
