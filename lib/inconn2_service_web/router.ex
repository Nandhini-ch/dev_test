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
    get "/sites?active=true", SiteController, :index
    get "/sites?active=false", SiteController, :index
    put "/sites/:id/activate", SiteController, :activate_site
    put "/sites/:id/deactivate", SiteController, :activate_site
    get "/download_sites", ReferenceDownloadController, :download_sites
    post "/upload_sites", ReferenceUploadController, :upload_sites

    resources "/asset_categories", AssetCategoryController, except: [:new, :edit]
    get "/asset_categories_tree", AssetCategoryController, :tree
    get "/asset_categories/nodes/leaves", AssetCategoryController, :leaves
    get "/asset_categories/:id/assets", AssetCategoryController, :assets
    put "/asset_categories/:id/deactivate", AssetCategoryController, :deactivate_asset_category
    put "/asset_categories/:id/activate", AssetCategoryController, :activate_asset_category
    get "/download_asset_categories", ReferenceDownloadController, :download_asset_categories
    post "/upload_asset_categories", ReferenceUploadController, :upload_asset_categories

    resources "/locations", LocationController, except: [:new, :edit, :index]
    put "/locations/:id/activate", LocationController, :activate_location
    put "/locations/:id/deactivate", LocationController, :deactivate_location
    get "/sites/:site_id/locations", LocationController, :index
    get "/sites/:site_id/locations_tree", LocationController, :tree
    get "/sites/:site_id/locations/leaves", LocationController, :leaves
    get "/download_locations", ReferenceDownloadController, :download_locations
    post "/upload_locations", ReferenceUploadController, :upload_locations

    resources "/equipments", EquipmentController, except: [:new, :edit, :index]
    get "/sites/:site_id/equipments", EquipmentController, :index
    get "/sites/:site_id/equipments_tree", EquipmentController, :tree
    get "/sites/:site_id/equipments/leaves", EquipmentController, :leaves
    put "/equipments/:id/activate", EquipmentController, :activate_equipment
    put "/equipments/:id/deactivate", EquipmentController, :deactivate_equipment
    get "/equipments/:equipment_id/location_path", EquipmentController, :loc_path
    get "/locations/:location_id/equipments", EquipmentController, :loc_equipments
    get "/download_equipments", ReferenceDownloadController, :download_equipments
    post "/upload_equipments", ReferenceUploadController, :upload_equipments


    resources "/shifts", ShiftController, except: [:new, :edit]
    put "/shifts/:id/activate", ShiftController, :activate_shift
    put "/shifts/:id/deactivate", ShiftController, :deactivate_shift
    get "/download_shifts", ReferenceDownloadController, :download_shifts
    post "/upload_shifts", ReferenceUploadController, :upload_shifts
    resources "/bankholidays", HolidayController, except: [:new, :edit]
    put "/bankholidays/:id/activate", HolidayController, :activate_holiday
    put "/bankholidays/:id/deactivate", HolidayController, :deactivate_holiday
    get "/download_bankholidays", ReferenceDownloadController, :download_bankholidays
    post "/upload_bankholidays", ReferenceUploadController, :upload_bankholidays
    resources "/parties", PartyController, except: [:new, :edit]

    resources "/tasks", TaskController, except: [:new, :edit]
    put "/tasks/:id/activate", TaskController, :activate_task
    put "/tasks/:id/deactivate", TaskController, :deactivate_task
    get "/download_tasks", ReferenceDownloadController, :download_tasks
    post "/upload_tasks", ReferenceUploadController, :upload_tasks
    resources "/task_lists", TaskListController, except: [:new, :edit]
    put "/task_lists/:id/activate", TaskListController, :activate_task_list
    put "/task_lists/:id/deactivate", TaskListController, :activate_task_list
    get "/download_task_lists", ReferenceDownloadController, :download_task_lists
    post "/upload_task_lists", ReferenceUploadController, :upload_task_lists

    resources "/checks", CheckController, except: [:new, :edit]
    put "/checks/:id/activate", CheckController, :activate_check
    put "/checks/:id/deactivate", CheckController, :deactivate_check
    get "/download_checks", ReferenceDownloadController, :download_checks_lists
    post "/upload_checks", ReferenceUploadController, :upload_checks
    resources "/check_lists", CheckListController, except: [:new, :edit]
    put "/check_lists/:id/activate", CheckListController, :activate_check_list
    put "/check_lists/:id/deactivate", CheckListController, :deactivate_check_list
    get "/download_check_lists", ReferenceDownloadController, :download_check_lists
    post "/upload_check_lists", ReferenceUploadController, :upload_check_lists

    resources "/workorder_templates", WorkorderTemplateController, except: [:new, :edit]
    resources "/workorder_schedules", WorkorderScheduleController, except: [:new, :edit]
    resources "/work_orders", WorkOrderController, except: [:new, :edit]
    get "/work_orders_of_user", WorkOrderController, :work_orders_of_user
    resources "/workorder_tasks", WorkorderTaskController, except: [:new, :edit]
    get "/work_orders/:work_order_id/workorder_tasks", WorkorderTaskController, :index_by_workorder
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
    put "/org_units/:id/activate", OrgUnitController, :activate_org_unit
    put "/org_units/:id/deactivate", OrgUnitController, :deactivate_org_unit


    get "/parties/:party_id/employees", EmployeeController, :index
    resources "/employees", EmployeeController, except: [:new, :edit, :index]
    put "/employees/:id/activate", EmployeeController, :activate_employee
    put "/employees/:id/deactivate", EmployeeController, :deactivate_employee
    get "/download_employees", ReferenceDownloadController, :download_employees
    post "/upload_employees", ReferenceUploadController, :upload_employees
    resources "/users", UserController, except: [:new, :edit]
    put "/users/change_password", UserController, :change_password
    put "/users/:id/activate", UserController, :activate_user
    put "/users/:id/deactivate", UserController, :deactivate_user
    get "/download_users", ReferenceDownloadController, :download_users
    resources "/modules", ModuleController, only: [:index, :show]
    get "/modules/:module_id/features", FeatureController, :index
    resources "/role_profiles", RoleProfileController, only: [:index, :show]
    resources "/roles", RoleController, except: [:new, :edit]
    put "/roles/:id/activate", RoleController, :active_role
    put "/roles/:id/deactivate", RoleController, :deactivate_role

    resources "/employee_rosters", EmployeeRosterController, except: [:new, :edit]
    get "/download_employee_rosters", ReferenceDownloadController, :download_employee_rosters
    post "/upload_employee_rosters", ReferenceUploadController, :upload_employee_rosters

    get "/employees", EmployeeRosterController, :employees
    resources "/attendances", AttendanceController, only: [:index, :create, :show]

    get "/sessions/current_user", SessionController, :current_user

    resources "/workrequest_categories", WorkrequestCategoryController, except: [:new, :edit]
    put "/workrequest_categories/:id/activate", WorkrequestCategoryController, :activate_workrequest_category
    put "/workrequest_categories/:id/deactivate", WorkrequestCategoryController, :deactivate_workrequest_category

    resources "/category_helpdesks", CategoryHelpdeskController, except: [:new, :edit]

    resources "/work_requests", WorkRequestController, except: [:new, :edit]
    get "/work_requests/:work_request_id/attachment", WorkRequestController, :get_attachment
    resources "/workrequest_status_tracks", WorkrequestStatusTrackController, [:new, :edit]

    resources "/suppliers", SupplierController, except: [:new, :edit]
    resources "/supplier_items", SupplierItemController, except: [:new, :edit]
    get "/items/:item_id/suppliers", SupplierItemController, :get_suppliers_for_item
    resources "/uoms", UOMController, except: [:new, :edit]
    get "/uoms/physical", UOMController, :index_physical
    get "/uoms/cost", UOMController, :index_cost
    resources "/uom_conversions", UomConversionController, except: [:new, :edit]
    post "/uoms/convert/:value/from/:from_uom_id/to/:to_uom_id", UomConversionController, :convert
    get "/items/spares", ItemController, :index_spares
    get "/items/tools", ItemController, :index_tools
    get "/items/consumables", ItemController, :index_consumables
    resources "/items", ItemController, except: [:new, :edit]


    resources "/inventory_locations", InventoryLocationController, except: [:new, :edit, :index]
    get "/sites/:site_id/inventory_locations/", InventoryLocationController, :index

    get "/inventory_locations/:inventory_location_id/inventory_stocks", InventoryStockController, :index
    get "/inventory_locations/:inventory_location_id/inventory_transactions", InventoryTransactionController, :loc_transaction
    get "/inventory_locations/:inventory_location_id/inventory_transfers", InventoryTransferController, :loc_transfer


    # resources "/inventory_stocks", InventoryStockController, except: [:new, :edit, :create, :update]
    get "/inventory_transaction/purchase", InventoryTransactionController, :index_by_transaction_type_purchase
    get "/inventory_transaction/issue", InventoryTransactionController, :index_by_transaction_type_issue
    get "/inventory_transaction/return", InventoryTransactionController, :index_by_transaction_type_return

    get "/inventory_locations/:inventory_location_id/inventory_transactions/purchase", InventoryTransactionController, :loc_transaction_purchase
    get "/inventory_locations/:inventory_location_id/inventory_transactions/issue", InventoryTransactionController, :loc_transaction_issue
    get "/inventory_locations/:inventory_location_id/inventory_transactions/return", InventoryTransactionController, :loc_transaction_purchase

    resources "/inventory_transactions", InventoryTransactionController, except: [:new, :edit]
    resources "/inventory_transfers", InventoryTransferController, except: [:new, :edit]
  end
end
