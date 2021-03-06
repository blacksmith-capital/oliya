defmodule Oliya.Backend.Postgres.Retriever do
  alias Oliya.Backend.Postgres.Retriever.OhlcQuery

  alias Oliya.Backend.Retriever

  @behaviour Retriever

  @impl Retriever
  def fetch(%Retriever.Params{} = params) do
    {:ok, query_response, {adjusted_from, adjusted_to}} = OhlcQuery.get(params)

    response = %Retriever.Reseponse{
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
end
