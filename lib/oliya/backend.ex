defmodule Oliya.Backend do
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
