defmodule Inconn2ServiceWeb.Router do
  use Inconn2ServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Inconn2ServiceWeb do
    pipe_through :api
  end
end
