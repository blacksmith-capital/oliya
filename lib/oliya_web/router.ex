defmodule OliyaWeb.Router do
  use OliyaWeb, :router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OliyaWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", OliyaWeb.Api do
    pipe_through :api

    scope "/v1", V1 do
      get "/ohlc", OhlcController, :index
    end
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard"
    end
  end
end
