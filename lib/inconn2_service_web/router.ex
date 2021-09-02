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
    get "/asset_categories/:id/assets", AssetCategoryController, :assets

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
    resources "/parties", PartyController, except: [:new, :edit]

    resources "/tasks", TaskController, except: [:new, :edit]
    resources "/task_lists", TaskListController, except: [:new, :edit]

    resources "/timezones", TimezoneController, only: [:index, :create]
    get "/timezones_search", TimezoneController, :search

    resources "/workorder_templates", WorkorderTemplateController, except: [:new, :edit]
    resources "/workorder_schedules", WorkorderScheduleController, except: [:new, :edit]
    get "/workorder_schedules/:id/next_schedule", WorkorderScheduleController, :next_schedule

    resources "/org_units", OrgUnitController, except: [:new, :edit, :index]
    get "/parties/:party_id/org_units", OrgUnitController, :index
    get "/parties/:party_id/org_units_tree", OrgUnitController, :tree
    get "/parties/:party_id/org_units/leaves", OrgUnitController, :leaves

    resources "/employees", EmployeeController, except: [:new, :edit]
    resources "/users", UserController, except: [:new, :edit]
  end
end
