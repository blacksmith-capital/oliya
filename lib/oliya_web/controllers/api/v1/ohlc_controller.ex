defmodule OliyaWeb.Api.V1.OhlcController do
  use OliyaWeb, :controller
  alias Oliya.Backend.Retriever

  def index(conn, params) do
    {:ok, data} =
      params
      |> Retriever.to_params()
      |> Retriever.fetch()

    json(conn, data |> Map.from_struct())
  end
end
