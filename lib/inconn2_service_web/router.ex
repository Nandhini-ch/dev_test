defmodule Inconn2ServiceWeb.Router do
  use Inconn2ServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug Inconn2ServiceWeb.Plugs.MatchTenantPlug
  end

  pipeline :authenticate do
    plug(Inconn2ServiceWeb.Plugs.GuardianAuthPipeline)
    plug(Inconn2ServiceWeb.Plugs.AssignUser)
  end

  scope "/api", Inconn2ServiceWeb do
    pipe_through :api
    resources "/business_types", BusinessTypeController, except: [:new, :edit]
    resources "/licensees", LicenseeController, except: [:new, :edit]

    post "/sessions/login", SessionController, :login
  end

  scope "/api", Inconn2ServiceWeb do
    pipe_through [:api, :authenticate]
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
    get "/locations/:location_id/equipments", EquipmentController, :loc_equipments

    resources "/shifts", ShiftController, except: [:new, :edit]
    resources "/bankholidays", HolidayController, except: [:new, :edit]
    resources "/parties", PartyController, except: [:new, :edit]

    resources "/timezones", TimezoneController, only: [:index, :create, :show]

    resources "/tasks", TaskController, except: [:new, :edit]
    resources "/task_lists", TaskListController, except: [:new, :edit]

    resources "/checks", CheckController, except: [:new, :edit]
    resources "/check_lists", CheckListController, except: [:new, :edit]

    resources "/workorder_templates", WorkorderTemplateController, except: [:new, :edit]
    resources "/workorder_schedules", WorkorderScheduleController, except: [:new, :edit]

    get "/workorder_templates/:id/work_permitted", WorkorderTemplateController, :work_permitted
    get "/workorder_templates/:id/loto_locked", WorkorderTemplateController, :loto_locked
    get "/workorder_templates/:id/in_progress", WorkorderTemplateController, :in_progress
    get "/workorder_templates/:id/completed", WorkorderTemplateController, :completed
    get "/workorder_templates/:id/loto_released", WorkorderTemplateController, :loto_released
    get "/workorder_templates/:id/cancelled", WorkorderTemplateController, :cancelled
    get "/workorder_templates/:id/hold", WorkorderTemplateController, :hold

    resources "/org_units", OrgUnitController, except: [:new, :edit, :index]
    get "/parties/:party_id/org_units", OrgUnitController, :index
    get "/parties/:party_id/org_units_tree", OrgUnitController, :tree
    get "/parties/:party_id/org_units/leaves", OrgUnitController, :leaves

    resources "/employees", EmployeeController, except: [:new, :edit]
    resources "/users", UserController, except: [:new, :edit]
  end
end
