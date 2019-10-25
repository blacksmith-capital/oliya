defmodule OliyaWeb.PageController do
  use OliyaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
