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
    get "/timezones", TimezoneController, :index

    post "/sessions/login", SessionController, :login
  end

  scope "/api", Inconn2ServiceWeb do
    pipe_through [:api, :authenticate]
    resources "/sites", SiteController, except: [:new, :edit]
    get "/download_sites", ReferenceDownloadController, :download_sites

    resources "/asset_categories", AssetCategoryController, except: [:new, :edit]
    get "/asset_categories_tree", AssetCategoryController, :tree
    get "/asset_categories/nodes/leaves", AssetCategoryController, :leaves
    get "/asset_categories/:id/assets", AssetCategoryController, :assets

    resources "/locations", LocationController, except: [:new, :edit, :index]
    get "/sites/:site_id/locations", LocationController, :index
    get "/sites/:site_id/locations_tree", LocationController, :tree
    get "/sites/:site_id/locations/leaves", LocationController, :leaves
    get "/download_locations", ReferenceDownloadController, :download_locations
    post "/upload_locations", ReferenceUploadController, :upload_locations

    resources "/equipments", EquipmentController, except: [:new, :edit, :index]
    get "/sites/:site_id/equipments", EquipmentController, :index
    get "/sites/:site_id/equipments_tree", EquipmentController, :tree
    get "/sites/:site_id/equipments/leaves", EquipmentController, :leaves
    get "/equipments/:equipment_id/location_path", EquipmentController, :loc_path
    get "/locations/:location_id/equipments", EquipmentController, :loc_equipments
    get "/download_equipments", ReferenceDownloadController, :download_equipments

    resources "/shifts", ShiftController, except: [:new, :edit]
    resources "/bankholidays", HolidayController, except: [:new, :edit]
    resources "/parties", PartyController, except: [:new, :edit]

    resources "/tasks", TaskController, except: [:new, :edit]
    resources "/task_lists", TaskListController, except: [:new, :edit]

    resources "/checks", CheckController, except: [:new, :edit]
    resources "/check_lists", CheckListController, except: [:new, :edit]

    resources "/workorder_templates", WorkorderTemplateController, except: [:new, :edit]
    resources "/workorder_schedules", WorkorderScheduleController, except: [:new, :edit]
    resources "/work_orders", WorkOrderController, except: [:new, :edit]
    resources "/workorder_tasks", WorkorderTaskController, except: [:new, :edit]
    get "/workorder_status_tracks/:work_order_id", WorkorderStatusTrackController, :index

    put "/work_orders/:id/work_permitted", WorkOrderController, :work_permitted
    put "/work_orders/:id/loto_locked", WorkOrderController, :loto_locked
    put "/work_orders/:id/in_progress", WorkOrderController, :in_progress
    put "/work_orders/:id/completed", WorkOrderController, :completed
    put "/work_orders/:id/loto_released", WorkOrderController, :loto_released
    put "/work_orders/:id/cancelled", WorkOrderController, :cancelled
    put "/work_orders/:id/hold", WorkOrderController, :hold

    resources "/org_units", OrgUnitController, except: [:new, :edit, :index]
    get "/parties/:party_id/org_units", OrgUnitController, :index
    get "/parties/:party_id/org_units_tree", OrgUnitController, :tree
    get "/parties/:party_id/org_units/leaves", OrgUnitController, :leaves

    resources "/employees", EmployeeController, except: [:new, :edit]
    resources "/users", UserController, except: [:new, :edit]
    resources "/roles", RoleController, except: [:new, :edit]
    get "/sessions/current_user", SessionController, :current_user

    resources "/employee_rosters", EmployeeRosterController, except: [:new, :edit]
    resources "/workrequest_categories", WorkrequestCategoryController, except: [:new, :edit]
  end
end
