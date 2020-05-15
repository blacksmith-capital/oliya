defmodule Oliya.HistoryPurger do
  use GenServer

  @cleanse_every 1000 * 60

  def start_link(state), do: GenServer.start_link(__MODULE__, state, name: __MODULE__)

  def init(_state) do
    case Application.get_env(:oliya, :cleanse_after_ms, :noop) do
      after_ms when is_integer(after_ms) ->
        queue_purger()
        {:ok, %{clean_after_ms: after_ms}}

      :noop ->
        :ignore
    end
  end

  def handle_info(:cleanse, %{clean_after_ms: after_ms} = state) do
    queue_purger()

    {:ok, _} =
      :millisecond
      |> :os.system_time()
      |> Kernel.-(after_ms)
      |> DateTime.from_unix!(:millisecond)
      |> Oliya.History.PostgresWorker.Trade.delete_before()

    {:noreply, state}
  end

  def queue_purger do
    Process.send_after(self(), :cleanse, @cleanse_every)
  end
end
