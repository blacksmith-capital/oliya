defmodule OliyaWeb.Api.V1.OhlcController do
  use OliyaWeb, :controller
  alias Oliya.Retriever

  def index(conn, params) do
    {:ok, fetch_params} =
      params
      |> Mapail.map_to_struct(Retriever.Params)

    {:ok, data} = Retriever.fetch(fetch_params)

    json(conn, data |> Map.from_struct())
  end
end
