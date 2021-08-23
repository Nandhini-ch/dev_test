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

    resources "/asset_categories", AssetCategoryController, except: [:new, :edit]
    get "/asset_categories_tree", AssetCategoryController, :tree
    get "/asset_categories/nodes/leaves", AssetCategoryController, :leaves

    resources "/locations", LocationController, except: [:new, :edit, :index]
    get "/sites/:site_id/locations", LocationController, :index
    get "/sites/:site_id/locations_tree", LocationController, :tree
    get "/sites/:site_id/locations/leaves", LocationController, :leaves

    resources "/equipments", EquipmentController, except: [:new, :edit, :index]
    get "/sites/:site_id/equipments", EquipmentController, :index
    get "/sites/:site_id/equipments_tree", EquipmentController, :tree
    get "/sites/:site_id/equipments/leaves", EquipmentController, :leaves

    resources "/shifts", ShiftController, except: [:new, :edit]
    resources "/bankholidays", HolidayController, except: [:new, :edit]

    resources "/tasks", TaskController, except: [:new, :edit]
    resources "/task_lists", TaskListController, except: [:new, :edit]
  end
end
