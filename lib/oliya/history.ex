defmodule Oliya.History do
  defmodule Backend do
    @type event :: map

    @doc "Receives an event and inserts into the backend"
    @callback insert(event) :: {:ok, event} | {:error, atom}
  end

  defmodule Worker do
    @moduledoc """
    Subscrive to trade events and collect history into persisted store
    """
    use GenServer

    defmodule State do
      defstruct [:backend]
    end

    @type event :: map
    @type level :: TaiEvents.level()
    @type state :: :ok

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
      {:ok, state}
    end

    @spec handle_info({TaiEvents.Event, event, level}, state) :: {:noreply, state}
    def handle_info({TaiEvents.Event, event, _level}, %{backend: backend} = state) do
      {:ok, _model} = backend.insert(event)
      {:noreply, state}
    end
  end
end
