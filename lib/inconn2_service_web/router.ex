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

    resources "/iot_meterings", IotMeteringController, only: [:create, :show]
  end

  scope "/api", Inconn2ServiceWeb do
    pipe_through [:api, :authenticate]
    resources "/sites", SiteController, except: [:new, :edit]
    get "/download_sites", ReferenceDownloadController, :download_sites
    post "/upload_sites", ReferenceUploadController, :upload_sites

    resources "/asset_categories", AssetCategoryController, except: [:new, :edit]
    get "/asset_categories_tree", AssetCategoryController, :tree
    get "/asset_categories/nodes/leaves", AssetCategoryController, :leaves
    get "/asset_categories/:id/assets", AssetCategoryController, :assets
    get "/download_asset_categories", ReferenceDownloadController, :download_asset_categories
    post "/upload_asset_categories", ReferenceUploadController, :upload_asset_categories

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
    post "/upload_equipments", ReferenceUploadController, :upload_equipments


    resources "/shifts", ShiftController, except: [:new, :edit]
    get "/download_shifts", ReferenceDownloadController, :download_shifts
    post "/upload_shifts", ReferenceUploadController, :upload_shifts
    resources "/bankholidays", HolidayController, except: [:new, :edit]
    get "/download_bankholidays", ReferenceDownloadController, :download_bankholidays
    post "/upload_bankholidays", ReferenceUploadController, :upload_bankholidays
    resources "/parties", PartyController, except: [:new, :edit]

    resources "/tasks", TaskController, except: [:new, :edit]
    resources "/task_lists", TaskListController, except: [:new, :edit]
    get "/download_tasks", ReferenceDownloadController, :download_tasks
    post "/upload_tasks", ReferenceUploadController, :upload_tasks
    get "/download_task_lists", ReferenceDownloadController, :download_task_lists
    post "/upload_task_lists", ReferenceUploadController, :upload_task_lists

    resources "/checks", CheckController, except: [:new, :edit]
    resources "/check_lists", CheckListController, except: [:new, :edit]
    get "/download_checks", ReferenceDownloadController, :download_checks
    post "/upload_checks", ReferenceUploadController, :upload_checks
    get "/download_check_lists", ReferenceDownloadController, :download_check_lists
    post "/upload_check_lists", ReferenceUploadController, :upload_check_lists

    resources "/workorder_templates", WorkorderTemplateController, except: [:new, :edit]
    resources "/workorder_schedules", WorkorderScheduleController, except: [:new, :edit]
    resources "/work_orders", WorkOrderController, except: [:new, :edit]
    resources "/workorder_tasks", WorkorderTaskController, except: [:new, :edit]
    get "/workorder_status_tracks/:work_order_id", WorkorderStatusTrackController, :index
    get "/download_workorder_templates", ReferenceDownloadController, :download_workorder_templates
    post "/upload_workorder_templates", ReferenceUploadController, :upload_workorder_templates
    get "/download_workorder_schedules", ReferenceDownloadController, :download_workorder_schedules
    post "/upload_workorder_schedules", ReferenceUploadController, :upload_workorder_schedules


    resources "/org_units", OrgUnitController, except: [:new, :edit, :index]
    get "/download_org_units", ReferenceDownloadController, :download_org_units
    post "/upload_org_units", ReferenceUploadController, :upload_org_units
    get "/parties/:party_id/org_units", OrgUnitController, :index
    get "/parties/:party_id/org_units_tree", OrgUnitController, :tree
    get "/parties/:party_id/org_units/leaves", OrgUnitController, :leaves

    resources "/employees", EmployeeController, except: [:new, :edit]
    get "/download_employees", ReferenceDownloadController, :download_employees
    post "/upload_employees", ReferenceUploadController, :upload_employees
    resources "/users", UserController, except: [:new, :edit]
    get "/download_users", ReferenceDownloadController, :download_users
    resources "/roles", RoleController, except: [:new, :edit]
    get "/sessions/current_user", SessionController, :current_user

    resources "/employee_rosters", EmployeeRosterController, except: [:new, :edit]
    get "/download_employee_rosters", ReferenceDownloadController, :download_employee_rosters
    post "/upload_employee_rosters", ReferenceUploadController, :upload_employee_rosters
    resources "/workrequest_categories", WorkrequestCategoryController, except: [:new, :edit]
  end
end
