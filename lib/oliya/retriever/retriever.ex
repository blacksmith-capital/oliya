defmodule Oliya.Retriever do
  alias Oliya.Retriever.Postgres.OhlcQuery

  defmodule Params do
    @enforce_keys ~w(from to symbol granularity venue)a
    defstruct ~w(from to symbol granularity venue)a
  end

  defmodule Reseponse do
    @derive Jason.Encoder
    @enforce_keys ~w(columns data venue symbol from to granularity)a
    defstruct ~w(columns data venue symbol from to granularity)a
  end

  def fetch(%Params{} = params) do
    from = params.from |> to_datetime()
    to = params.to |> to_datetime()

    {:ok, query_response, {adjusted_from, adjusted_to}} =
      %{
        from: from,
        to: to,
        symbol: params.symbol |> String.downcase(),
        venue: params.venue |> String.downcase(),
        granularity: params.granularity
      }
      |> OhlcQuery.get()

    response = %Reseponse{
      from: adjusted_from,
      to: adjusted_to,
      symbol: params.symbol,
      venue: params.venue,
      granularity: params.granularity,
      data: query_response.data,
      columns: query_response.columns
    }

    {:ok, response}
  end

  defp to_datetime(timestamp),
    do: timestamp |> String.to_integer(10) |> DateTime.from_unix!(:millisecond)
end
