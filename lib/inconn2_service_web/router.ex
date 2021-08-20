defmodule Inconn2ServiceWeb.Router do
  use Inconn2ServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Inconn2ServiceWeb.Plugs.MatchTenantPlug
  end

  scope "/api", Inconn2ServiceWeb do
    pipe_through :api
    resources "/business_types", BusinessTypeController, except: [:new, :edit]
    resources "/licensees", LicenseeController, except: [:new, :edit]
    resources "/sites", SiteController, except: [:new, :edit]
    resources "/locations", LocationController, except: [:new, :edit, :index]
    get "/sites/:site_id/locations", LocationController, :index
    get "/sites/:site_id/locations_tree", LocationController, :tree
    get "/sites/:site_id/locations/leaves", LocationController, :leaves
    resources "/asset_categories", AssetCategoryController, except: [:new, :edit, :index]
    get "/sites/:site_id/asset_categories", AssetCategoryController, :index
    get "/sites/:site_id/asset_categories_tree", AssetCategoryController, :tree
    get "/sites/:site_id/asset_categories/leaves", AssetCategoryController, :leaves

  end
end
