defmodule Inconn2ServiceWeb.Router do
  use Inconn2ServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Inconn2ServiceWeb do
    pipe_through :api
    resources "/business_types", BusinessTypeController, except: [:new, :edit]
    resources "/licensees", LicenseeController, except: [:new, :edit]
  end
end
