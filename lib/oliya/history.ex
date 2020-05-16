defmodule Oliya.History do
  defmodule Backend do
    alias Oliya.History.Backend.{Postgres, Tectonicdb}
    @type event :: map

    @doc "Receives an event and inserts into the backend"
    @callback insert(event) :: {:ok, event} | {:error, atom}

    def mod, do: Application.get_env(:oliya, :backend, Tectonicdb)

    def child_spec(args \\ []) do
      {backend_mod, opts} =
        case Keyword.get(args, :backend, mod()) do
          Postgres -> {Oliya.Repo, args}
          Tectonicdb -> {ExTectonicdb, Keyword.merge(args, name: Tectonicdb)}
        end

      %{
        id: backend_mod,
        start: {backend_mod, :start_link, [opts]},
        restart: :permanent,
        shutdown: 5000,
        type: :worker
      }
    end
  end

  defmodule Worker do
    @moduledoc """
    Subscrive to trade events and collect history into persisted store
    """
    use GenServer

    defmodule State do
      defstruct backend: Oliya.History.Backend.mod()
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
