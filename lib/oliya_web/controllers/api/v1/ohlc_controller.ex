defmodule OliyaWeb.Api.V1.OhlcController do
  use OliyaWeb, :controller
  alias OliyaWeb.Fetcher

  def index(conn, params) do
    {:ok, fetch_params} =
      params
      |> Mapail.map_to_struct(Fetcher.Params)

    {:ok, data} = Fetcher.fetch(fetch_params)

    json(conn, data |> Map.from_struct())
  end
end
