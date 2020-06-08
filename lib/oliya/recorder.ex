defmodule Oliya.Recorder do
  defmodule Backend do
    @type trade_event :: %{
            price: float,
            qty: float,
            side: :buy | :sell,
            symbol: atom,
            timestamp: non_neg_integer,
            venue_id: atom
          }
    @type order_event :: %{
            price: float,
            qty: float,
            seq: non_neg_integer,
            side: :bid | :ask,
            symbol: atom,
            timestamp: non_neg_integer,
            venue_id: atom
          }
    @type event :: trade_event | order_event

    @doc "Receives an event and inserts into the backend"
    @callback insert(event) :: {:ok, any} | {:error, reason :: atom}
  end

  defmodule Worker do
    @moduledoc """
    Subscrive to trade events and collect history into persisted store
    """
    use GenServer

    defmodule State do
      @type t :: %State{
              backend: module
            }

      defstruct [:backend]
    end

    @type event :: map
    @type level :: TaiEvents.level()
    @type state :: State.t()

    @subscribe_to [
      Tai.Events.Trade
    ]

    def start_link(args) do
      opts = Keyword.take(args, [:backend])
      state = struct(State, opts)

      GenServer.start_link(__MODULE__, state, name: __MODULE__)
    end

    @spec init(state) :: {:ok, state}
    def init(state) do
      Enum.each(@subscribe_to, &TaiEvents.subscribe/1)
      Tai.SystemBus.subscribe(:change_set)
      {:ok, state}
    end

    @type trade_event :: {TaiEvents.Event, event, level}
    @type order_event :: {:change_set, map}
    @spec handle_info(trade_event | order_event, state) :: {:noreply, state}
    def handle_info({TaiEvents.Event, event, _level}, %{backend: backend} = state) do
      {:ok, _model} = backend.insert(event)
      {:noreply, state}
    end

    def handle_info(
          {:change_set,
           %{changes: changes, last_received_at: monotonic_ts, symbol: symbol, venue: venue_id}},
          %{backend: backend} = state
        ) do
      timestamp =
        monotonic_ts
        |> Kernel.+(System.time_offset())
        |> System.convert_time_unit(:native, :microsecond)

      changes
      |> Enum.with_index()
      |> Enum.map(fn
        {{:upsert, side, price, qty}, seq} ->
          %{
            price: price,
            side: side,
            symbol: symbol,
            timestamp: timestamp,
            venue_id: venue_id,
            qty: qty,
            seq: seq
          }

        {{:delete, side, price}, seq} ->
          %{
            price: price,
            side: side,
            timestamp: timestamp,
            symbol: symbol,
            venue_id: venue_id,
            qty: 0,
            seq: seq
          }
      end)
      |> Enum.each(&backend.insert(&1))

      {:noreply, state}
    end
  end
end
